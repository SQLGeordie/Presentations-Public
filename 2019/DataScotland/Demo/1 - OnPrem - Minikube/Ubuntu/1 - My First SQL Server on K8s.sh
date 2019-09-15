# Move to correct directory
cd ~/demo/


#Start minikube
minikube start #--vm-driver=hyperv --memory=10000 --cpus=4 --hyperv-virtual-switch="External"
#minikube start --vm-driver=hyperv --memory=10000 --cpus=4 --hyperv-virtual-switch="External"
##### This takes ~4mins #####

# Check the status
sudo minikube status



# confirm kubectl context
kubectl config current-context



# list contexts
kubectl config get-contexts



# switch context to local cluster
kubectl config use-context minikube



# confirm kubectl context
kubectl config current-context

# View your config 
kubectl config view

#ssh into minikube
sudo minikube ssh

# check images
docker images

# view nodes
kubectl get nodes



# deploy pod
#kubectl delete deployment minikube-sqlserver
kubectl run minikube-sqlserver --image=mcr.microsoft.com/mssql/server:2017-latest-ubuntu \
                        --env ACCEPT_EULA=Y \
                        --env SA_PASSWORD=P@ssword1 \
                        --env MSSQL_BACKUP_DIR=/var/opt/mssql/backups/ \
                        --env MSSQL_DATA_DIR=/var/opt/mssql/data/ \
                        --env MSSQL_LOG_DIR=/var/opt/mssql/data/ \
                        --labels="app=minikube-sqlserver,env=demo"
:'
kubectl run minikube-sqlserver --image=mcr.microsoft.com/mssql/server:2019-RC1-ubuntu `
                        --env ACCEPT_EULA=Y `
                        --env SA_PASSWORD=P@ssword1 `
                        --env MSSQL_BACKUP_DIR=/var/opt/mssql/backups/ `
                        --env MSSQL_DATA_DIR=/var/opt/mssql/data/ `
                        --env MSSQL_LOG_DIR=/var/opt/mssql/logs/ `
                        --labels="app=minikube-sqlserver,env=demo"
'

# view deployment
kubectl get deployments



# view pod
# switch to BASH here!!!
kubectl get pods -o wide
podname=( $(kubectl get pods -o wide --all-namespaces | grep sqlserver- ) )
kubectl logs ${podname[1]} #| more



# exec into pod
#kubectl exec -it :'enter-pod-here' bash
kubectl exec -i -t "$(kubectl get pod -l "app=minikube-sqlserver" -o jsonpath='{.items[0].metadata.name}')" -- bash



# navigate to sqlcmd
cd /opt/mssql-tools/bin/



# connect to sql
./sqlcmd -S . -U sa -P "P@ssword1" -Q "select @@version; select name from sys.databases"


# exit SQL and pod
exit


# expose service
# Need to expose a service to connect via ADS, ClusterIP will work, LB will need to wait for external IP to generate ~2min
kubectl expose deployment minikube-sqlserver --type=ClusterIP --port=1433 --target-port=1433 
kubectl expose deployment minikube-sqlserver --name=sqlserverlb --type=LoadBalancer --port=1433 --target-port=1433 
kubectl expose deployment minikube-sqlserver --name=sqlservernp --type=NodePort --port=1433 --target-port=1433 
#kubectl expose deployment nginx-deployment --type=LoadBalancer --port=1433 --target-port=1433


# get service IP
kubectl get services

kubectl describe service minikube-sqlserver

minikube service list

# Open minikube dashboard
minikube dashboard


# Open Tunnel
:'
sudo minikube tunnel

# deploy dashboard for Docker for Windows K8s
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# start proxy
kubectl proxy

# connect to dashboard
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

# get token
kubectl -n kube-system describe secret
'

#Scale out - doesn't work when persisting storage due to SQL Server not letting you have 2 processes accessing the same files!
kubectl get pods -o wide
kubectl scale deployment/minikube-sqlserver --replicas=2

# Check for 2 pods
kubectl get pods -o wide
kubectl scale deployment/minikube-sqlserver --replicas=1
kubectl get pods -o wide


# clean up
kubectl delete deployment minikube-sqlserver
kubectl delete service minikube-sqlserver
kubectl delete service sqlserverlb
kubectl delete service sqlservernp
