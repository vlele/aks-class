#***************************************************************************************
## Objective: This module demonstrates installing a MYSQl Pod using Helm in AKS and connecting it from another Pod in the same AKS. 
#***************************************************************************************

#note: default helm install name 

cd ../m13

NAMESPACE=mysqlhelm
kubectl create namespace $NAMESPACE
MYSQL_HELM_PACKAGE_NAME="my-release"
# Create and set context to "$namespace" namespace

# Create a Service Account 
kubectl create serviceaccount -n kube-system tiller
# Create a cluster role binding
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#--> Configure Helm and apply a Bug Fix to use the tiller service account.  Ref: https://github.com/helm/helm/issues/6374
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -

#--> Update Helm repo
helm repo update

#-->  Install mysql 
helm install --name $MYSQL_HELM_PACKAGE_NAME stable/mysql
#-->  helm del --purge my-special-installation

#--> 1. launch an Ubuntu pod
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il
apt update
apt install wget

#--> 2. Install the mysql client:
apt-get update && apt-get install mysql-client -y

#--> Now switch to another terminal and obtain the mysql password by executing below command. It is a base64 encoded value. Be sure to decode it
kubectl get secret my-release-mysql -o jsonpath="{.data.mysql-root-password}"
#--> # Go to the URL https://www.base64decode.org and decode the String received above. The decode output  --> 0yESiQ0A0H

#-->  Also print the same of the service by typing svcs"
#--> . Connect using the mysql-client, then provide your password:

svcs # note the name of my sql service
mysql -h my-release-mysql -p
#mysql -h my-release-mysql -p
show databases;

#*don't* exit from the Ububtu - jump to network policy module 

# Cleanup Steps:
# don't cleanup until module #16
