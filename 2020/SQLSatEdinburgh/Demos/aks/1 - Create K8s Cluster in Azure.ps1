# switch to powershell terminal
powershell.exe
cd "C:\K8sDemo\Demo\2 - Azure Kubernetes Service" 

#Install Azure Powershell module
Install-Module -Name Az -AllowClobber -Scope AllUsers
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

#Connect to Azure
Connect-AzAccount


#If you have multiple subscriptions, you can optionally set the subscription you wish to use in the SUBSCRIPTION-NAME placeholder.
az account show
az account set --subscription "<<Enter Subscription Name Here>>"

#Create a resource group and cluster. The cluster creation process can take up to 20 minutes
$resourcegroup = 'aks-rg-demo'
$aksclustername = 'aks-cluster-demo'
$aksclustername2 = 'aks-cluster-demo-2'
$ACR = 'jclaksacrdemo'
# Create Resource Group
az group create --name $resourcegroup --location UKWest #eastus

# Create AKS Cluster
az aks create --name $aksclustername --resource-group $resourcegroup --node-count 3 --node-vm-size Standard_B2s --generate-ssh-keys #--node-vm-size Standard_DS2_v2
#az aks create --name $aksclustername --resource-group $resourcegroup --node-count 1 --node-vm-size Standard_B2s --generate-ssh-keys #--attach-acr $ACR

#Standard_B2s
# Install Kubernetes cli
az aks install-cli
az account clear
az login
az aks get-credentials --name $aksclustername --resource-group $resourcegroup

# confirm kubectl context
kubectl config get-contexts
kubectl config current-context

# switch context to local cluster
kubectl config use-context $aksclustername

#Attach ACR to cluster
az extension add --name aks-preview
az aks update -n $aksclustername -g $resourcegroup --attach-acr $ACR

#Create New ACR
az acr create --resource-group $resourcegroup --name $ACR --sku Basic
az acr login --name $ACR
docker pull mcr.microsoft.com/mssql/server:2017-cu16-ubuntu
docker tag mcr.microsoft.com/mssql/server:2017-cu16-ubuntu jclaksacrdemo.azurecr.io/mssqldemo:2017-cu16
docker tag mcr.microsoft.com/mssql/server:2017-cu17-ubuntu jclaksacrdemo.azurecr.io/mssqldemo:2017-cu17

docker push jclaksacrdemo.azurecr.io/mssqldemo:2017-cu16
docker push jclaksacrdemo.azurecr.io/mssqldemo:2017-cu17
az acr repository list --name $ACR --output table
az acr repository show -n $ACR --image mssqldemo:2017-cu16