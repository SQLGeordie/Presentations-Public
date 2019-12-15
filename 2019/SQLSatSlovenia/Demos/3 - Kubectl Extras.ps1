kubectl cluster-info #dump

kubectl get nodes

kubectl get nodes -o wide

kubectl get pods --namespace kube-system -o wide

kubectl get all --all-namespaces | less

kubectl api-resources | head -n 10 

kubectl api-resources | grep pod

kubectl explain pod | less

kubectl explain pod.spec | less

kubectl explain pod.spec.containers | less

kubectl explain deployment.spec.template.spec.containers.resources.limits.memory | less

kubectl describe nodes minikube

kubectl get services --namespace ingress-nginx nginx-ingress-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'

#Get External IP from LoadBalancer
$serv=kubectl get services aks-sqlserver-service --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo $serv

#Obvs can't do this on Windows :(
sudo apt-get install bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

kubectl -h | more

kubectl get -h | more

kubectl describe -h | less
