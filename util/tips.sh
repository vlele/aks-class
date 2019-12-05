https://github.com/LeCoupa/awesome-cheatsheets/blob/master/languages/bash.sh

Cnt E
CNTRL A
CNTRL K

//preview
az extension add --name aks-preview

Kubectl logs
kubectl logs m1pod
OLD_IMAGES=$(docker images |awk '{if (($4 > 10 && $5 == "minutes")) {print $3}}')
docker rmi ${OLD_IMAGES[@]}
docker system prune

kubectl exec -it shell-demo -- /bin/bash

# set alias
alias k='kubectl'
KUBE_EDITOR="nano"

az aks browse --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME

kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

k config view
k top node

k delete pods --all

127.0.0.1:8001


# Edit 
export EDITOR=nano  Cntrl O, Enter Cntrl X

# Create namspace mongo 
kubectl create serviceaccount --namespace kube-system tiller

kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' 

# Install install 
helm install stable/mysql --name my-special-installation --set mysqlPassword=password 

#launch an Ubuntu pod

kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il 
apt update
 apt install wget

2. Install the mysql client:

apt-get update && apt-get install mysql-client -y

# Get root password
MYSQL_ROOT_PASSWORD=$(kubectl get secret  my-special-installation-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)
echo $MYSQL_ROOT_PASSWORD


3. Connect using the mysql cli, then provide your password:
mysql -h my-special-installation-mysql -p 
L1NeOYgjuP
4. 
#exit from the Ububtu
exit

# apply network policy
kubectl apply -f backend-policy.yaml


helm ls 
helm delete <installation>
To connect to your database directly from outside the K8s cluster:
    MYSQL_HOST=127.0.0.1
    MYSQL_PORT=3306


# HELM install Grafana and Prometheus 
# Create namespace / Set context
helm install stable/prometheus-operator --name test



kubectl get serviceaccount | grep 'istio'|awk '{print $1}'|xargs kubectl delete serviceaccount
kubectl get clusterrole | grep 'istio'|awk '{print $1}'|xargs kubectl delete clusterrole
kubectl get clusterrolebindings | grep 'istio'|awk '{print $1}'|xargs kubectl delete clusterrolebindings

# cleanup CRDs
kubectl get serviceaccount -n istio-system | grep 'istio'|awk '{print $1}'|xargs kubectl delete serviceaccount  -n istio-system
kubectl get clusterrole  -n istio-system | grep 'istio'|awk '{print $1}'|xargs kubectl delete clusterrole  -n istio-system
kubectl get customresourcedefinition  -n istio-system | grep 'alertmanagers'|awk '{print $1}'|xargs kubectl delete customresourcedefinition  -n istio-system
kubectl get customresourcedefinition  -n istio-system | grep 'monitoring'|awk '{print $1}'|xargs kubectl delete customresourcedefinition  -n istio-system
kubectl get clusterrolebindings  -n istio-system | grep 'istio'|awk '{print $1}'|xargs kubectl delete clusterrolebindings  -n istio-system

# Helm RBAC
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' 
