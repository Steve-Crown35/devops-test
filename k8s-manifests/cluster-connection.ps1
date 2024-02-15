Start-Transcript -Path "C:\agent\_work\10\s\script_execution.log"

# Download Chocolatey installer script

# Define the directory path
$directoryPath = "C:\temp"

# Check if the directory exists
if (-not (Test-Path -Path $directoryPath -PathType Container)) {
    # If the directory does not exist, create it
    New-Item -Path $directoryPath -ItemType Directory
} else {
    Write-Output "Directory already exists."
}
Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -OutFile C:\temp\choco-install.ps1

# Run Chocolatey installer script
Set-ExecutionPolicy Bypass -Scope Process -Force; `
    . C:\temp\choco-install.ps1 

# Ensure Chocolatey is in the system PATH
refreshenv

# Get Chocolatey version
$chocoVersion = choco --version

# Print Chocolatey version
Write-Host "Chocolatey version: $chocoVersion"

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
refreshenv

# Get Azure CLI version
$azVersion = az --version

# Print Azure CLI version to console
Write-Output "Azure CLI Version: $azVersion"

# Get the path of the Azure CLI executable
$azExecutablePath = (Get-Command az).Source

# Print the path to the console
Write-Host "Path of Azure CLI executable: $azExecutablePath"

# Install Azure PowerShell module with automatic response
choco install az.powershell -y


# Connect to kubernetes cluster

az account set --subscription 3b95c837-890a-4f1a-9488-ca9b0dc28d46

Write-Host "subscription set successfully"

az aks get-credentials --resource-group aks-resource-group --name dev-aks-cluster --overwrite-existing --file "C:\agent\_work\10\s\.kube\config"

Write-Host "Azure kubernestes credentials successfully obtained"
Test-Path "C:\agent\_work\10\s\.kube\config"
Get-Content "C:\agent\_work\10\s\.kube\config"


# Run rocketchat on kubernetes cluster

# Retrieve the cluster node resource group name
$clusterResourceGroup = 'aks-resource-group'
$clusterName = 'dev-aks-cluster'
$clusterDiskName = 'aksClusterdisk'
$clusterNodeResourceGroup = az aks show --resource-group $clusterResourceGroup --name $clusterName --query nodeResourceGroup -o tsv


# Check if the disk already exists in the resource group
$existingDisk = az disk show --name $clusterDiskName --resource-group $clusterNodeResourceGroup --query id -o tsv

if (-not [string]::IsNullOrWhiteSpace($existingDisk)) {
    Write-Host "Disk $clusterDiskName already exists in resource group $clusterNodeResourceGroup."
    $diskResourceId = $existingDisk
} else {
    Write-Host "Disk $clusterDiskName does not exist in resource group $clusterNodeResourceGroup. Creating it..."
    # Construct the az disk create command
    $diskResourceId = az disk create --resource-group $clusterNodeResourceGroup --name $clusterDiskName --sku StandardSSD_LRS --size-gb 20 --zone 1 --query id --output tsv
    
    Write-Host "Disk $clusterDiskName created successfully"
}

# Define the Kubernetes manifest file path
$manifestFilePath = "k8s-manifests\pv-azuredisk.yaml"

# Read the content of the Kubernetes manifest file
$manifestContent = Get-Content -Path $manifestFilePath -Raw

# Update the volumeHandle in the manifest content with the disk resource ID
$updatedManifestContent = $manifestContent -replace 'volumeHandle: (.*)', "volumeHandle: $diskResourceId"

# Write the updated manifest content back to the file
Set-Content -Path $manifestFilePath -Value $updatedManifestContent
Write-Host "persistent volume manifest updated successfully"


# Change ownership of the config file to the current user

$owner = (Get-Item "C:\agent\_work\10\s\.kube\config").GetAccessControl().Owner
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($owner, "FullControl", "Allow")
$acl = (Get-Item "C:\agent\_work\10\s\.kube\config").GetAccessControl('Access')
$acl.SetOwner([System.Security.Principal.NTAccount]$owner)
$acl.SetAccessRule($rule)
Set-Acl -Path "C:\agent\_work\10\s\.kube\config" -AclObject $acl
Write-Host "Ownership changed successfully"

# Authenticate selfhosted agent to access kubernetes cluster


#write-host "kubelogin installation with winget was successfully"
#refreshenv
$spn_client_id="spn-client-id"
$spn_client_secret="spn-client-secret"
$keyvault_name="initinfrakv"


# Get secrets from azure keyvault
$ServicePrincipalClientID="az keyvault secret show --name $spn_client_id --vault-name $keyvault_name --query 'value'"
Write-Host "Obtained service principal client Id"
$ServicePrincipalClientSecret="az keyvault secret show --name $spn_client_secret --vault-name $keyvault_name --query 'value'"
Write-Host "Obtained service principal secrets"

# Authenticate agent to the cluster
$kubeconfigPath = "C:\agent\_work\10\s\.kube\config"
Write-Host "set kube config path"
$env:KUBECONFIG=$kubeconfigPath
Write-Host "set kube config Environment Variable"
kubelogin convert-kubeconfig -l spn --client-id $ServicePrincipalClientID --client-secret $ServicePrincipalClientSecret
Write-Host "converted kube config to an executable file for kubectl authentication to the azure kubernetes cluster"
# Run commands on the cluster using the agent
kubectl get nodes

# Create kubernetes objects from manifests
kubectl create -f k8s-manifests