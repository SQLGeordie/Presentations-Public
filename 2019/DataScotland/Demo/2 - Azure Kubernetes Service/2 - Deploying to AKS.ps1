# Connect to Azure and set subscription
Connect-AzAccount
az account show
az account set --subscription "JCL-PAYG"


#Set parameters for script
$VMresourcegroupname = '<<VM Resource Group Name Here>>'
$VMName = '<<VM Name Here>>'
$resourcegroup = 'JCL-DevOps' #'aks-rg-demo'
$aksclustername = 'DevOps-K8s-Test' #'aks-cluster-demo'
$deploymentname = 'aks-sqlserver'

#Start VM
get-azvm
Start-AzVM -ResourceGroupName <<VM Resource Group Name Here>> -Name <<VM Name Here>>

# Install Kubernetes cli
az aks install-cli
az aks get-credentials --name $aksclustername --resource-group $resourcegroup

# Move to Demo folder
cd "C:\K8sDemo\Demo\2 - Azure Kubernetes Service"


# confirm kubectl context
kubectl config current-context

# switch context to local cluster
kubectl config use-context $aksclustername

#Open Browser
#az aks Get-Credentials --resource-group $resourcegroup --name $aksclustername
az aks browse --resource-group $resourcegroup --name $aksclustername

#Checking aks, remove if exists
kubectl get all


#Deploy SQL Server and Service to AKS
cat aks-sqlserver.yaml
kubectl apply -f aks-sqlserver.yaml

#Checking aks again
kubectl get all -o wide

# Check the pod is up and running
podname=( $(kubectl get pods -o wide --all-namespaces | grep aks-sqlserver- ) )
kubectl logs ${podname[1]} 

# Exec into the pod
kubectl exec -i -t "$(kubectl get pod -l "name=aks-sqlserver" -o jsonpath='{.items[0].metadata.name}')" -- bash

cd /opt/mssql-tools/bin/

./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"

./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"

exit


#Scale out
kubectl get pods -o wide
kubectl scale deployment/aks-sqlserver --replicas=2

# Check for 2 pods
kubectl get pods -o wide
kubectl scale deployment/aks-sqlserver --replicas=1
kubectl get pods -o wide

#Switch Image
kubectl rollout history deployment/aks-sqlserver         
kubectl set image deployment/aks-sqlserver aks-sqlserver=jcldevops.azurecr.io/azuredevops:latest2019              
kubectl rollout history deployment/aks-sqlserver
#NOTE: This can take up to 1 min

#Query the k8s 2019
# Check the pod is up and running
podname=( $(kubectl get pods -o wide --all-namespaces | grep aks-sqlserver- ) )
kubectl logs ${podname[1]} 
kubectl exec -i -t "$(kubectl get pod -l "name=aks-sqlserver" -o jsonpath='{.items[0].metadata.name}')" -- bash
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"
exit


#Remove deployment
kubectl delete deployment aks-sqlserver
kubectl delete service aks-sqlserver-service

# Check cluster 
kubectl cluster-info #dump
kubectl get all

#Stop VM
Connect-AzAccount
get-azvm 
Stop-AzVM -ResourceGroupName <<VM Resource Group Name Here>> -Name <<VM Name Here>>


#Delete Resource Group
#az group delete --name <<ResourceGroupNameHere>>