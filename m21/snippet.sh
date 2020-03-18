##***************************************************************************************
## Objective: This module demos the KEDA(Kubernetes-based event-driven autoscaling) based solution in AKS.  
#***************************************************************************************
## Pre-requisites:
#    - User should have a AKS Cluster already and running in East US/Central US/West US 2/West Europe/Canada Central/Canada East region
#		> .\create-azkeda-demo-cluster.ps1 "eastus" "ais-azkeda-rg" "azkeda-demo"
#    - Have a storage account("kedastorageacc"),  a queue named "js-queue-items", 
#    - Configure the AllowedHeaders & ExposedHeaders in CORS configuration to * i.e. allow all headers & return all headers
#	    Go to Azure Portal "Home -> Resource groups -> $rg_name -> $storageaccname - CORS". Enter the below inputs and click "Save"
#	    "ALLOWED ORIGINS = *" 
#	    "ALLOWED METHODS  = "GET, POST, PUT and PATCH
#	    "ALLOWED HEADERS = *" 
#	    "EXPOSED HEADERS = *"  
#	    "MAX AGE = 10"  
# 	 - Register providers needed for AKS cluster
#	    > az provider register -n Microsoft.ContainerInstance
#	    > az provider register -n Microsoft.ContainerService
#	 - Install npm from https://nodejs.org/en/download/(node-v10.16.3-x64.msi) and add ";C:\Program Files\nodejs\" to the Path environment variable
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m21 module directory
   > cd ..\m21
   
#--> Before we create a  “ImagePullSecret”, we change the kubectl context to default namespace,
   > kubectl config set-context $(kubectl config current-context) --namespace=default

#--> Create a  “ImagePullSecret” by giving your e-mail id, docker-server  and ACR password
   > kubectl create secret docker-registry hello-keda-secret --docker-server democncfarchacr.azurecr.io --docker-email Itesh.Simlai@appliedis.com --docker-username=democncfarchacr --docker-password  <ACR-Repository-Pwd>    
   
#--> Get the Service Account by executing below command and update the  "serviceaccount.yml" file  
   > kubectl get serviceaccounts default -o yaml > ./serviceaccount.yml
   > update the "serviceaccount.yml" as below,
#--> secrets:
#-->	- name: hello-keda-secret
#--> Execute the below command to update serviceaccount, 
   > kubectl replace serviceaccount default -f ./serviceaccount.yml   
   
#--> Install KEDA using a HELM chart (Refer:https://pixelrobots.co.uk/2020/02/what-is-keda-and-how-do-i-deploy-it/)
#--> Create namespace keda
   > kubectl create namespace keda
#--> Download the "keda-master.zip" from https://github.com/kedacore/keda and unzip the same. Then execute below steps,
   > kubectl apply -f keda-master/deploy/crds/keda.k8s.io_scaledobjects_crd.yaml
   > kubectl apply -f keda-master/deploy/crds/keda.k8s.io_triggerauthentications_crd.yaml
   > kubectl apply -f keda-master/deploy/ 
#--> Confirm that KEDA has been successfully installed. The output should show "scaledobjects.keda.k8s.io" object
   > kubectl get customresourcedefinition  
   
#--> Update the "hello-keda/local.settings.json" with the correct Connection String of the Azure Queue and the do Base64 encoding using the below link:
#--> https://www.base64encode.org/  and paste it into the "manifests/deploy.yaml" at data --> AzureWebJobsStorage: ....
#--> Then build the image as below and use it in the "manifests/deploy.yaml" deployment
   > az acr login --name democncfarchacr1
   > cd hello-keda
   > docker build -t democncfarchacr1.azurecr.io/hello-keda .
   > docker push democncfarchacr1.azurecr.io/hello-keda  
   
#--> Update the "deploy.yaml" file with below lines and then deploy the Azure Function to AKS
#--> imagePullSecrets:
#--> 	- name: hello-keda-secret
   > kubectl apply -f manifests/deploy.yaml   

#--> Do some tests to check that the KEDA is working  correctly in AKS. First run the below command in PowerShell and ensure that you see '0' KEDA created pods in default namespace. 
   > kubectl get pods

# Add few messages to the Queue in Azure Portal: "Home -> Resource groups -> $rg_name -> $storageaccname - Queues -> js-queue-items". Click "+ Add message"

#--> Verify in the PowerShell window new Pods are being created by running the below command and destroyed afterwards
kubectl get pods -w


# Cleanup Steps:
   > helm delete namespace keda  
   > kubectl delete -f keda-master/deploy/crds/keda.k8s.io_scaledobjects_crd.yaml
   > kubectl delete -f keda-master/deploy/crds/keda.k8s.io_triggerauthentications_crd.yaml
   > kubectl delete -f keda-master/deploy/
   > kubectl delete -f manifests/deploy.yaml
   > kubectl delete Secret hello-keda-secret
