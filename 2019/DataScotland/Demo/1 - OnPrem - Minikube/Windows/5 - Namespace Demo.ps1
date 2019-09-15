# Move to correct directory
cd "C:\K8sDemo\Demo\1 - OnPrem - Minikube\Windows\"

# switch context to local cluster
kubectl config use-context minikube

# Clean Up
kubectl get all --namespace nsdemo
kubectl delete namespace nsdemo
kubectl config unset contexts.demo
kubectl config use-context minikube
kubectl get all --all-namespaces

# Check what namespaces we have
kubectl get namespace

# Create a new namespace
kubectl create namespace nsdemo

# Create and change to a new context using that namespace
kubectl config view
kubectl config current-context
kubectl config set-context demo --namespace=nsdemo --cluster=minikube --user=minikube
kubectl config use-context demo
kubectl config get-contexts 

kubectl get deployment -n nsdemo

# Deploy SQL 2019 in that context
kubectl run minikube-sqlserver --image=mcr.microsoft.com/mssql/server:2017-latest-ubuntu \
                        --env ACCEPT_EULA=Y \
                        --env SA_PASSWORD=P@ssword1 \
                        --env MSSQL_BACKUP_DIR=/var/opt/mssql/backups/ \
                        --env MSSQL_DATA_DIR=/var/opt/mssql/data/ \
                        --env MSSQL_LOG_DIR=/var/opt/mssql/data/ 

kubectl get deployment -n nsdemo

kubectl get deployment -o wide
kubectl get pods -o wide --all-namespaces
kubectl get pods -l run=minikube-sqlserver

podname=( $(kubectl get pods -o wide --all-namespaces | grep minikube- ) )
kubectl logs ${podname[1]} #| more

kubectl config use-context minikube
kubectl config get-contexts 

kubectl get deployment -o wide

kubectl config use-context demo

kubectl get deployment -o wide

# Cleanup
kubectl delete namespace nsdemo
kubectl get namespace -o wide
kubectl config get-contexts
kubectl config unset contexts.demo
kubectl config use-context minikube
kubectl config get-contexts 
kubectl get all --all-namespaces
kubectl config use-context minikube
