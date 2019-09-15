# Move to correct directory
cd "C:\K8sDemo\Demo\1 - OnPrem - Minikube\Windows"

# switch context to local cluster
kubectl config use-context minikube

# Clean Up
kubectl get all
kubectl delete deployment minikube-sqlserver
kubectl delete service minikube-sqlserver-service
kubectl delete service sqlservernp
kubectl delete service sqlserverlb
kubectl delete secret minikube-mssql
kubectl delete pvc pvc-minikube-mssql-systemdbs
kubectl delete pvc pvc-minikube-mssql-data
kubectl delete pvc pvc-minikube-mssql-logs
kubectl delete sc sc-minikube-demo

kubectl apply -f storageclass_minikube.yaml
kubectl apply -f persistentvolumeclaim_minikube.yaml
kubectl create secret generic minikube-mssql --from-literal=SA_PASSWORD="P@ssword1"

# Deploy SQL 2019 - early version
kubectl apply -f sqlserver_persistentvolume_minikube_2019_CTP3.2.yaml

# Check the logs
podname=( $(kubectl get pods -o wide --all-namespaces | grep minikube- ) )
kubectl logs ${podname[1]} #| more

#kubectl exec -it :'enter-pod-here' bash
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "CREATE DATABASE Demo2;"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"

exit



#Switch Image - NOTE: This can take ~5mins!!!!
kubectl rollout history deployment/minikube-sqlserver   

kubectl apply -f sqlserver_persistentvolume_minikube_2019_RC1.yaml      
# OR use
kubectl set image deployment/minikube-sqlserver minikube-sqlserver=mcr.microsoft.com/mssql/server:2019-RC1-ubuntu

kubectl rollout history deployment/minikube-sqlserver 

# Check pod again
podname=( $(kubectl get pods -o wide --all-namespaces | grep minikube- ) )
echo ${podname[1]}
kubectl logs ${podname[1]} #| more
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# navigate to sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"

exit

# Check Deployment to see the image used
kubectl get deployments -o wide

# rollback
kubectl rollout history deployment/minikube-sqlserver
kubectl rollout undo deployment minikube-sqlserver #--to-revision=2

# Check Deployment to see the image used
kubectl get deployments -o wide

# Check the pod is up and running
podname=( $(kubectl get pods -o wide --all-namespaces | grep minikube- ) )
echo ${podname[1]}
kubectl logs ${podname[1]} #| more
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# navigate to sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"

exit


#Scale out - doesn't work when persisting storage due to SQL Server not letting you have 2 processes accessing the same files!
kubectl get pods -o wide
kubectl scale deployment/minikube-sqlserver --replicas=2

# Check for 2 pods
kubectl get pods -o wide
kubectl scale deployment/minikube-sqlserver --replicas=1
kubectl get pods -o wide

# Cleanup
kubectl delete deployment minikube-sqlserver
kubectl delete service minikube-sqlserver-service
kubectl delete service sqlservernp
kubectl delete service sqlserverlb
kubectl delete secret minikube-mssql
kubectl delete pvc pvc-minikube-mssql-systemdbs
kubectl delete pvc pvc-minikube-mssql-data
kubectl delete pvc pvc-minikube-mssql-logs
kubectl delete sc sc-minikube-demo

kubectl get all --all-namespaces 
kubectl get no -o wide --all-namespaces 