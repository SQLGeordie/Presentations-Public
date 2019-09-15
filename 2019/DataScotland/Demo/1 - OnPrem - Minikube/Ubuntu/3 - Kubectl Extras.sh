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

sudo apt-get install bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

kubectl -h | less

kubectl get -h | less

kubectl describe -h | less
