# switch to powershell terminal
powershell

#Install Azure Powershell module
Install-Module -Name Az -AllowClobber -Scope AllUsers

#Connect to Azure
Connect-AzAccount
az login

#If you have multiple subscriptions, you can optionally set the subscription you wish to use in the SUBSCRIPTION-NAME placeholder.
az account show
az account set --subscription "<<Enter Subscription Name Here>>"

#Create a resource group and cluster. The cluster creation process can take up to 20 minutes
$resourcegroup = 'aks-rg-demo'
$aksclustername = 'aks-cluster-demo'

# Create Resource Group
az group create --name $resourcegroup --location UKWest #eastus

# Create AKS Cluster
az aks create --name $aksclustername --resource-group $resourcegroup --node-count 3 --node-vm-size Standard_DS2_v2 --generate-ssh-keys

# Install Kubernetes cli
az aks install-cli
az aks get-credentials --name $aksclustername --resource-group $resourcegroup

# confirm kubectl context
kubectl config get-contexts
kubectl config current-context

# switch context to local cluster
kubectl config use-context $aksclustername