# Deploying Rocket.Chat on Kubernetes with Terraform and Azure DevOps Pipeline
This guide explains how to deploy a Rocket.Chat instance on Kubernetes using Terraform for infrastructure provisioning and Azure DevOps pipelines for automation. 


# Prerequisites

Before you begin, ensure you have the following:
* A code editor of your choice - Microsoft Visual Studio code or Pycharm
* A version control tool example git
* An Azure account with appropriate permissions to create resources. You can create a free azure account here: https://azure.microsoft.com/en-us/free
* Azure CLI installed locally for managing Azure resources.
* Azure Kubernetes Service client tools - kubectl and kubelogin
* Terraform CLI installed locally for infrastructure provisioning.
* An Azure DevOps organization and project set up.
* Service principal with appropriate permissions on azure subscription and resourcegroup for setting up azure devops service connection as well as appropriate access policy for service principal on azure keyvault.

# Setup

# 1. Clone the Repository
Clone the repository containing the Terraform configuration and Azure DevOps pipeline definitions:
```bash
git clone <repository-url>
cd <repository-directory>

```
Remove git from the repository using the following command:
```bash
rm -rf .git
```
Go to your azure devops organization, create a new project, initialize it repository and clone it to your machine.
Copy and paste the contents of the first repository, which is now a non-git repository into your azure devops repository. 
Push and commit your changes.
# 2. Update Terraform Variables
Navigate to the terraform directory and update the variables.tf file with your desired configuration parameters, such as Azure region, resource group name, Kubernetes cluster name, etc.
There are two seperate configurations for terraform :
*  **init-infra**: for initial infrastructure setup like storage account for remote backend, keyvault for storing infrastructure credentials for azure devops pipeline agent.
* **aks**: for azure kuberntes service.

# 3. Configure Azure DevOps Pipeline
Set up a new pipeline in your Azure DevOps project to trigger the Terraform deployment. You can use the provided azure-pipelines.yml file in the azure-pipeline folder in the repository as a starting point. The pipeline deploys kubernetes cluster and create rocket.chat instance v6.5.2 in on the cluster.


Ensure you have configured appropriate service connections and variables in Azure DevOps for accessing Azure resources and secrets securely.

To use this solution, you must configure the following role assignments for the underlying service connection service principal:
* **Contributor Role** for service connection service principal to create and manage resources on the subscription.
* **Application Administrator** role to service connection service principal to create and manage apps in Microsoft Entra ID.
* Create keyvault **Access Policy** for service connection service principal to allow service principal to GET, LIST and SET secrets on azure keyvault. The following secrets must be created and added in **initinfrakv** keyvault: 
  * azure devops organization url
  * azure devops personal access token
  * service connection service principal client ID
  * service connection service principal client secret

# 4. Deploy Infrastructure
To deploy infrastructure, begin by navigating into the init-infra folder and run the following commands to setup the storage account for terraform remote backend and azure keyvault for storing service principal secrets:
```bash
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```
Go to your azure devops project, navigate to **Pipelines ---> Environments** and create 3 environments **dev**, **test** and **prod**. 

 Once initial infrastructure is deployed and azure devops environments created, trigger the Azure DevOps pipeline to run the Terraform deployments in aks folder. This will provision Azure  Kubernetes cluster.

 To trigger the pipeline: 
 * Navigate to Pipelines in your project.
 * Click **New Pipeline** 
 * Choose Azure git repository
 * Select build from and existing pipeline.
 * Select the appropriate pipeline for your deployment:
 
    * **azure-pipelines.yml** to deploy azure kubernetes cluster
    * **rocketchat-deployment.yml** to deploy rocket chat instatnce v6.5.2
# Note: 
The pipelines use an azure self-hosted windows agent. For steps on how to install and run an azure self-hosted agent visit https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/windows-agent?view=azure-devops 
* Setup your self-hosted agent and provide it name to **pool_type** parameter in azure-pipeline.yml and pool **name** in rocketchat-deployment.yml file

The rocketchat-deployment.yml pipeline runs a powershell script which deploys rocket.chat manifests to azure kubernetes cluster provisioned by triggering azure-pipeline.yml pipeline.

Make sure to modify the script; k8s-manifests/cluster-connection.ps1, to use the authentication credentials you have created. 

Also modify the kube\config path - "C:\agent\_work\10\s\.kube\config", to align with the installation path of your Windows agent. 
Use the following command to create the kubeconfig path to store cluster connection credentials:
```bash
$USERPROFILE\.kube\config
```
Finally, download and install AzAksCliTool (which consists of kubectl and kubelogin) on the windows agent. Do this by first running the command:
```pwsh
Install-AzAksCliTool
```
on your local machine. Find the path where the binaries are, usually install to your home directory. Copy the folders: .azure-kubectle and .azure-kubelogin to the **bin** folder of your agent.
# Deploying Rocket.Chat
# 1. Apply Kubernetes Manifests
After successful deployment of kubernetes cluster, manually trigger the rocketchat-deployment.yml pipeline to create rocket.chat instance v6.5.2 on the cluster.

# 2. Access Rocket.Chat
* Navigate to portal.azure.com. 
* On the home page, type kubernetes servives.
* Click open your cluster and on the **overview** page, click on **Connect** at the top.
* Copy the following commands and run them on the terminal of your editor: 
```bash
az account set --subscription <name-of-your-azure-subscription>

az aks get-credentials --resource-group <name of-cluster-resource-group> --name <name-of-azure-kubernetes-service-cluster> --overwrite-existing
```
* Run:
```bash
kubectl get svc
```
to get the services running on the kubernetes cluster. Rocket.chat service is exposed as a LoadBalancer type on port 3000.

* Copy the external-IP address and port 3000 to your browser like so: 
```bash
<EXTERNAL-IP>:3000
```
There you have it! Your rock.chat instance is ready for use.Log on and start using it.

# Cleanup
To clean up the resources created by Terraform and Azure DevOps:

Destroy the Terraform-managed infrastructure by simply running the pipeline and selecting _**destroy**_ as pipeline action. This will remove azure kubernetes cluster and its associated components. 

Remove the init-infra resources by running 
```bash
terraform destroy 
```
 on your terminal



# Troubleshooting
If you encounter any issues during deployment, refer to the logs generated by Terraform and Azure DevOps pipelines for error messages. You can also check the status of Kubernetes resources using **_kubectl describe_** command.

# Contributing
Contributions are welcome! If you find any issues or have suggestions for improvement, feel free to open an issue or submit a pull request.

# License
This project is licensed under the MIT License.

# Appendix
# Important To Note
* Rocket.chat instance uses mongodb as backend. You must setup deployment and service manifest for mongodb and pass the mongodb url to rocketchat deployment as environmental variable.
like so: 
```yaml

apiVersion: apps/v1
kind: Deployment
metadata:

  labels:
    app-service: mongodb
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app-service: mongodb
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app-service: mongodb
    spec:
      containers:
      - env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        - name: MONGODB_ADVERTISED_HOSTNAME
          value: mongodb
        - name: MONGODB_ENABLE_JOURNAL
          value: "true"
        - name: MONGODB_INITIAL_PRIMARY_HOST
          value: mongodb
        - name: MONGODB_INITIAL_PRIMARY_PORT_NUMBER
          value: "27017"
        - name: MONGODB_PORT_NUMBER
          value: "27017"
        - name: MONGODB_REPLICA_SET_MODE
          value: primary
        - name: MONGODB_REPLICA_SET_NAME
          value: rs0
        image: docker.io/bitnami/mongodb:5.0
        name: mongodb
        volumeMounts:
        - mountPath: /mnt/azure
          name: mongodb-data
      restartPolicy: Always
      volumes:
      - name: mongodb-data
        persistentVolumeClaim:
          claimName: pvc-azuredisk

```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app-service: rocketchat
  name: rocketchat
spec:
  replicas: 1
  selector:
    matchLabels:
      app-service: rocketchat
      app: mongodb
  template:
    metadata:
      labels:
        app-service: rocketchat
        app: mongodb
    spec:
      containers:
      - env:
        - name: MONGO_OPLOG_URL
          value: mongodb://mongodb:27017/local?replicaSet=rs0
        - name: MONGO_URL
          value: mongodb://mongodb:27017/rocketchat?replicaSet=rs0
        - name: PORT
          value: "3000"
        - name: ROOT_URL
          value: http://localhost:3000
        image: rocket.chat:6.5.2
        name: rocketchat
        ports:
        - containerPort: 3000
          hostIP: 0.0.0.0
          hostPort: 3000
          protocol: TCP
      restartPolicy: Always
```
* Mongodb deployment requires a physical storage to persist data. You must create a persistent volume and reference it in a persistent volume claim for mongodb deployment volumes. You can use any cloud storage storage of your choice. If you are picking azure: 
  * ensure to create the azure data disk in the cluster's node resource group. **Note** that this is different from the cluster resource group. You can get the clusterNode resourcegroup with the following command:
  ```bash
  az aks show --resource-group <name-of-cluster-ResourceGroup> --name <name-of-cluster> --query nodeResourceGroup -o tsv
  ```
  * If you instead create the disk in a separate resource group, you must grant the Azure Kubernetes Service (AKS) managed identity for your cluster the **Contributor** role to the disk's resource group.
  * The disk must be created in the same region and zone of the cluster node. See https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision for more details.
