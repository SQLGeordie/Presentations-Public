# Move to correct directory
cd ~/demo/


# confirm kubectl context
kubectl config current-context



# switch context to local cluster
kubectl config use-context minikube


# view storage class yaml
cat storageclass_minikube.yaml



# create storage class
kubectl apply -f storageclass_minikube.yaml



# view storage class
kubectl get storageclass
kubectl get sc



# view persistent volume claim yaml
cat persistentvolumeclaim_minikube.yaml



# create persistent volume claim
kubectl apply -f persistentvolumeclaim_minikube.yaml



# view persistent volume claim
kubectl get persistentvolumeclaim
kubectl get pvc -o wide



# view persistent volume 
kubectl get persistentvolume
kubectl get pv -o wide



# create secret
kubectl create secret generic minikube-mssql2 --from-literal=SA_PASSWORD="P@ssword1"



# view secret
kubectl get secrets



# describe secret
kubectl describe secret minikube-mssql



# deploy sqlserver
kubectl apply -f sqlserver_persistentvolume_minikube.yaml

# check deployment
kubectl get deployments


# view logs
kubectl get pods -o wide
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
kubectl logs ${podname[1]} 

sudo minikube dashboard

# Expose nodeport to connect via ADS
kubectl expose deployment minikube-sqlserver --name=sqlservernp --type=NodePort --port=1433 --target-port=1433
kubectl expose deployment minikube-sqlserver --name=sqlserverlb --type=LoadBalancer --port=1433 --target-port=1433
kubectl get service -o wide

#If you have issues connecting via ADS and the IP given, try using the URL/Port from:
sudo minikube service list
# ie. default     | sqlserverlb | 192.168.0.29:32009 --> 192.168.0.29,32009



# Show in the dashboard
minikube dashboard

#kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml



# Show that the PVC isn't actually in the container/pod deployed. 
# The mount is in the minikube VM
#kubectl exec -it :'enter-pod-here' bash
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# navigate to sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "CREATE DATABASE Demo1;"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
cd /demo/data
ls
exit

# delete pod
kubectl delete pod ${podname[1]} #:'enter-pod-here'


# view new pod's IP address
kubectl get pods -o wide


#check it is completed starting up
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
kubectl logs ${podname[1]}

#kubectl exec -it :'enter-pod-here' bash
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# navigate to sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases;"
exit


# Test deleting the deployment and recreating - DB still exists
kubectl delete deployment minikube-sqlserver
#kubectl delete service minikube-sqlserver-service
####
kubectl apply -f sqlserver_persistentvolume_minikube.yaml


#kubectl exec -it :'enter-pod-here' bash
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# navigate to sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases;"
#./sqlcmd -S . -U sa -P "P@ssword1" -Q "CREATE DATABASE Demo1 ON (FILENAME = '/var/opt/mssqldata/Demo1.mdf'), (FILENAME = '/var/opt/mssqldata/Demo1_log.ldf') FOR ATTACH;"
#./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases;"
exit


# view persistent volume claim
kubectl get pvc
kubectl describe pvc "$(kubectl get pvc -o jsonpath='{.items[0].metadata.name}')"


# view volume
kubectl get pv 
kubectl describe pv "$(kubectl get pv -o jsonpath='{.items[0].metadata.name}')" #:'enter pv name here'



# Clean up all
kubectl delete deployment minikube-sqlserver
kubectl delete service minikube-sqlserver-service
kubectl delete service sqlservernp
kubectl delete secret minikube-mssql
kubectl delete pvc pvc-minikube-mssql-systemdbs
kubectl delete pvc pvc-minikube-mssql-data
kubectl delete pvc pvc-minikube-mssql-logs
kubectl delete sc sc-minikube-demo

#Rebuild all from Scratch if needed
:' 
kubectl apply -f storageclass_minikube.yaml
kubectl apply -f persistentvolumeclaim_minikube.yaml
kubectl create secret generic minikube-mssql --from-literal=SA_PASSWORD="P@ssword1"
kubectl apply -f sqlserver_persistentvolume_minikube.yaml

kubectl get pods -o wide
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
echo ${podname[1]}
kubectl logs ${podname[1]} #| more

kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "CREATE DATABASE Demo1;"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "USE Demo1; CREATE TABLE Test1 (ID INT); SELECT name FROM sys.Tables"
cd /var/opt/mssql/data
cd /demo/data
ls
exit

kubectl delete pod ${podname[1]} #:'enter-pod-here'

kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

cd /opt/mssql-tools/bin/

./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "USE Demo1; SELECT name FROM sys.Tables"
cd /demo/data
ls
exit
'