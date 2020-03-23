#***************************************************************************************
## Objective: This module demonstrates the OSBA in AKS. When you run this sample, the following things happen:
#***************************************************************************************

#--> Go to m17 module directory
cd ../m17

NAMESPACE="osba"
kubectl create namespace $NAMESPACE

#--> Execute the "install-helm-pre-requisites.sh" to create a service account, check tiller running in 'kube-system' and upgrade helm repo  
. install-helm-pre-requisites.sh

#--> Execute the "helper-sp-params.sh" and create a service principal that has rights on the subscription to create resources and initialize the variables  
. helper-sp-params.sh

#--> Install svc-cat/catalog
. install-catalog.sh

#--> Check the catalog installation. This is going to take "2-3" mins time
kubectl get pods -n catalog

#--> Deploy Open Service Broker for Azure
. install-broker.sh
#--> Check the catalog installation.It takes "2-3" mins. You may see status changing "CrashLoopBackOff/Error/Running", that's ok
kubectl get pods -n osba -w

#--> Edit the "mongodb-service-instance.yaml" file for correct "resourceGroup: aks-class-new". Deploy Resources with OSBA. Here we are deploying "azure-mongodb-instance"
kubectl create -f manifests/mongodb-service-instance.yaml
#--> Verify: A CosmosDB is created in the "$rg_name" resource group. Take a break till the "STATUS" is ready. It will take 8-9 mins.
kubectl get serviceinstance -w

#--> Edit "azure-mongodb-binding.yaml" file for correct "namespace: osba".  Create the binding that creates a secret with azure cosmos mongo database connection details.
kubectl create -f manifests/azure-mongodb-binding.yaml

#--> Deploy an application which writes to azure cosmos mongo database every 30 seconds. 
kubectl apply -f manifests/osba-cosmos-mongodb-demo.yaml
#--> Verification Steps: Check the CosmosDB Collections growing in VSCode or in Azure Portal

# Cleanup Steps:
kubectl delete -f manifests/osba-cosmos-mongodb-demo.yaml
kubectl delete -f manifests/azure-mongodb-binding.yaml

#-->  The following action will delete the CosmosDB in Azure Portal as well
kubectl delete -f manifests/mongodb-service-instance.yaml

helm del --purge catalog
helm del --purge osba
kubectl delete namespace $NAMESPACE
kubectl delete namespaces osba
kubectl delete namespaces catalog

 



