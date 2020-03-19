#***************************************************************************************
## Objective: This module demonstrates the OSBA in AKS. When you run this sample, the following things happen:
#***************************************************************************************

#--> Go to m17 module directory
cd ../m17

NAMESPACE="osba"
kubectl create namespace $NAMESPACE

#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
kubectl apply -f manifests/clusterrole-binding-sa.yaml

#--> Check all pods in AKS cluster 
kubectl get pods --all-namespaces --field-selector metadata.namespace!=kube-system

#--> Check that we have a Service Account("tiller") in the cluster. 
kubectl get serviceAccounts --all-namespaces

#--> Configure Helm to use the tiller service account 
helm init --upgrade --service-account tiller
helm repo update

#--> Execute the "helper-sp-params.sh" and create a service principal that has rights on the subscription to create resources and initialize the variables  
./helper-sp-params.sh

#--> Add the Service Catalog helm repo to helm 
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

#--> Install svc-cat/catalog
helm install svc-cat/catalog --name catalog --namespace catalog --set apiserver.storage.etcd.persistence.enabled=true --set apiserver.healthcheck.enabled=false --set controllerManager.healthcheck.enabled=false --set apiserver.verbosity=2 --set controllerManager.verbosity=2

#--> Check the catalog installation. This is going to take "2-3" mins time
kubectl get pods -n catalog

#--> Deploy Open Service Broker for Azure. First, we need to add the repo
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

#--> Deploy Open Service Broker for Azure
helm install azure/open-service-broker-azure --name osba --namespace osba --set azure.subscriptionId=$env:AZURE_SUBSCRIPTION_ID --set azure.tenantId=$env:AZURE_TENANT_ID --set azure.clientId=$env:AZURE_CLIENT_ID --set azure.clientSecret=$env:AZURE_CLIENT_SECRET

#--> Check the catalog installation.It takes "2-3" mins. You may see status changing "CrashLoopBackOff/Error/Running", that's ok
kubectl get pods -n osba -w

#--> Edit the "mongodb-service-instance.yaml" file for correct "resourceGroup: aks-class-new". Deploy Resources with OSBA. Here we are deploying "azure-mongodb-instance"
kubectl create -f manifests\mongodb-service-instance.yaml
#--> Verify: A CosmosDB is created in the "$rg_name" resource group. Take a break till the "STATUS" is ready. It will take 8-9 mins.
kubectl get serviceinstance -w

#--> Edit "azure-mongodb-binding.yaml" file for correct "namespace: osba".  Create the binding that creates a secret with azure cosmos mongo database connection details.
kubectl create -f manifests\azure-mongodb-binding.yaml

#--> Deploy an application which writes to azure cosmos mongo database every 30 seconds. 
kubectl apply -f manifests\osba-cosmos-mongodb-demo.yaml
#--> Verification Steps: Check the CosmosDB Collections growing in VSCode or in Azure Portal

# Cleanup Steps:
kubectl delete -f manifests\osba-cosmos-mongodb-demo.yaml
kubectl delete -f manifests\azure-mongodb-binding.yaml

#-->  The following action will delete the CosmosDB in Azure Portal as well
kubectl delete -f manifests\mongodb-service-instance.yaml

helm del --purge catalog
helm del --purge osba
kubectl delete namespace $NAMESPACE


 



