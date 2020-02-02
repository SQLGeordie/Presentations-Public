bash.exe

# Move to correct directory
cd "C:\K8sDemo\Demo\1 - OnPrem - Minikube\Windows"


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
kubectl describe pvc "$(kubectl get pvc -o jsonpath='{.items[0].metadata.name}')"


# view persistent volume created dynamically
kubectl get persistentvolume
kubectl get pv -o wide
kubectl describe pv "$(kubectl get pv -o jsonpath='{.items[0].metadata.name}')" #:'enter pv name here'


# create secret
kubectl create secret generic minikube-mssql --from-literal=SA_PASSWORD="P@ssword1"



# view secret
kubectl get secrets



# describe secret
kubectl describe secret minikube-mssql



# deploy sqlserver
kubectl delete deployment minikube-sqlserver

kubectl apply -f sqlserver_persistentvolume_minikube.yaml

# check deployment
kubectl get deployments


# view logs
kubectl get pods -o wide
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
kubectl logs ${podname[1]} #| more

minikube dashboard

# Expose nodeport to connect via ADS
kubectl expose deployment minikube-sqlserver --name=sqlservernp --type=NodePort --port=1433 --target-port=1433
kubectl expose deployment minikube-sqlserver --name=sqlserverlb --type=LoadBalancer --port=1433 --target-port=1433
kubectl get service -o wide

#If you have issues connecting via ADS and the IP given, try using the URL/Port from:
minikube service list
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
./sqlcmd -S . -U sa -P "P@ssword1" -Q "CREATE DATABASE Demo1;CREATE LOGIN [test1] WITH PASSWORD=N'P@ssword1', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
                                        EXEC sys.sp_configure N'max server memory (MB)', N'3000'
                                        RECONFIGURE WITH OVERRIDE
                                        GO"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases;SELECT name FROM syslogins WHERE [name] like 'test%';"
cd /demo/data
ls
exit

#play around a bit for a laugh, see it all fail :)
kubectl scale deployment/minikube-sqlserver --replicas=3
kubectl get pods -o wide
kubectl logs 'minikube-sqlserver-5bcf4b7b97-7jkrd' #| more
:' example error:
    Error 5(Access is denied.) occurred while opening file '/var/opt/mssql/data/master.mdf' to obtain configuration information at startup. 
    An invalid startup option might have caused the error. Verify your startup options, and correct or remove them if necessary.
'
kubectl scale deployment/minikube-sqlserver --replicas=1
kubectl get pods -o wide


# delete pod
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
kubectl delete pod ${podname[1]} #:'enter-pod-here'


# view new pod's IP address
kubectl get pods -o wide


#check it is completed starting up
kubectl get pods -o wide
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
kubectl logs ${podname[1]} #| more

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
kubectl get deployments
kubectl apply -f sqlserver_persistentvolume_minikube.yaml


#kubectl exec -it :'enter-pod-here' bash
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

# navigate to sqlcmd
cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases;SELECT name FROM syslogins WHERE [name] LIKE 'test%'"
exit



#### Try and Upgrade
kubectl rollout history deployment/minikube-sqlserver 

podname=( $(kubectl get pods -o wide --all-namespaces | grep minikube- ) )
echo ${podname[1]}
kubectl logs ${podname[1]} #| more
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

cd /opt/mssql-tools/bin/
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version"
exit

kubectl set image deployment/minikube-sqlserver minikube-sqlserver=mcr.microsoft.com/mssql/server:2017-cu17-ubuntu
kubectl get pods
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

kubectl set image deployment/minikube-sqlserver minikube-sqlserver=mcr.microsoft.com/mssql/server:2017-cu16-ubuntu
kubectl get pods
kubectl rollout history deployment/minikube-sqlserver 
##### End Patching


# Clean up all
kubectl delete deployment minikube-sqlserver
kubectl delete service minikube-sqlserver-service
kubectl delete service sqlservernp
kubectl delete service sqlserverlb
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

cd /demo/data
ls
exit

kubectl delete pod ${podname[1]} #:'enter-pod-here'

kubectl get pods -o wide
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-mssql" -o jsonpath='{.items[0].metadata.name}')" -- bash

cd /opt/mssql-tools/bin/

./sqlcmd -S . -U sa -P "P@ssword1" -Q "select name from sys.databases"
./sqlcmd -S . -U sa -P "P@ssword1" -Q "USE Demo1; SELECT name FROM sys.Tables"
cd /demo/data
ls
exit
'
