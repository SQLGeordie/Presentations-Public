# Connect to Azure and set subscription
powershell
Connect-AzAccount
az account show
az account set --subscription "<< Add Subscription Here >>"


#Set parameters for script
$resourcegroup = 'aks-rg-demo'
$aksclustername = 'aks-cluster-demo'

#Start VM
get-azvm 
$vm = get-azvm 
$vm.ResourceGroupName #[0]
$vm.Name #[0]
Start-AzVM -ResourceGroupName $vm.ResourceGroupName[0] -Name $vm.Name[0]
Start-AzVM -ResourceGroupName $vm.ResourceGroupName[1] -Name $vm.Name[1]
Start-AzVM -ResourceGroupName $vm.ResourceGroupName[2] -Name $vm.Name[2]


# Install Kubernetes cli
az aks install-cli
az aks get-credentials --name $aksclustername --resource-group $resourcegroup

# Move to Demo folder
cd "C:\K8sDemo\Demo\2 - Azure Kubernetes Service"


# confirm kubectl context
kubectl config current-context

# switch context to local cluster
kubectl config use-context $aksclustername

#Need to assign cluster role permissions to view dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

#Open Browser
#az aks Get-Credentials --resource-group $resourcegroup --name $aksclustername
az aks browse --resource-group $resourcegroup --name $aksclustername

#Checking aks, remove if exists
kubectl get all


#Deploy SQL Server and Service to AKS
bash
cat aks-sqlserver.yaml
kubectl apply -f aks-sqlserver.yaml
#kubectl apply -f aks-sqlserver-jcl.yaml

#Checking aks again
kubectl get nodes
kubectl get all -o wide
kubectl get pods -o wide

# Check the pod is up and running
podname=( $(kubectl get pods -o wide --all-namespaces | grep aks-sqlserver- ) )
echo ${podname[1]}
kubectl logs ${podname[1]} #| more
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
kubectl set image deployment/aks-sqlserver aks-sqlserver=jclaksacrdemo.azurecr.io/mssqldemo:2017-cu17             
kubectl get pods -o wide
kubectl rollout history deployment/aks-sqlserver
#NOTE: This can take up to 1 min

#Query the k8s 2019
# Check the pod is up and running
podname=( $(kubectl get pods -o wide --all-namespaces | grep aks-sqlserver- ) )
echo ${podname[1]}
kubectl logs ${podname[1]} #| more

#Jump into the pod
kubectl exec -i -t "aks-sqlserver-856d8b4fb-8rhfw" -- bash "$(kubectl get pod -l "name=aks-sqlserver" -o jsonpath='{.items[0].metadata.name}')" -- bash
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"
exit

#Switch Image back to previous 
kubectl rollout history deployment/aks-sqlserver         
kubectl set image deployment/aks-sqlserver aks-sqlserver=jclaksacrdemo.azurecr.io/mssqldemo:2017-cu16    
kubectl rollout history deployment/aks-sqlserver
#NOTE: This can take up to 1 min

#Remove deployment
kubectl delete deployment aks-sqlserver
kubectl delete service aks-sqlserver-service
<#
kubectl delete deployment aks-sqlserver-jcl
kubectl delete service aks-sqlserver-service
#>

# Check cluster 
kubectl cluster-info #dump
kubectl get all

#Stop VM
powershell
Connect-AzAccount
get-azvm 
Stop-AzVM -ResourceGroupName "<< Add ResourceGroupName here >>" -Name aks-agentpool-34059815-0


#Delete the AKS Cluster
az group delete --name $resourcegroup --yes --no-wait

#Stop everything
get-azvm 
$vm = get-azvm 
$vm.ResourceGroupName[0]
$vm.Name[0]
Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name
Stop-AzVM -ResourceGroupName $vm.ResourceGroupName[0] -Name $vm.Name[0]
Stop-AzVM -ResourceGroupName $vm.ResourceGroupName[1] -Name $vm.Name[1]
Stop-AzVM -ResourceGroupName $vm.ResourceGroupName[2] -Name $vm.Name[2]

#Delete Resource Group
#az group delete --name <<ResourceGroupNameHere>>