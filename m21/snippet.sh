##***************************************************************************************
## Objective: This module demos the KEDA
#***************************************************************************************

NAMESPACE=keda
kubectl create namespace $NAMESPACE
#--> Go to m21 module directory
cd ../m21

 helm repo add kedacore https://kedacore.github.io/charts
# Update Helm repo

 helm repo update
# Install keda Helm chart
helm install kedacore/keda --namespace $NAMESPACE --name keda
   
#--> Confirm that KEDA has been successfully installed. The output should show "scaledobjects.keda.k8s.io" object
kubectl get customresourcedefinition  

#--> Before we create a  “ImagePullSecret”, we change the kubectl context to default namespace,
kubectl config set-context $(kubectl config current-context) --namespace=default

#--> Create a  “ImagePullSecret” by giving your e-mail id and ,
kubectl create secret docker-registry hello-keda-secret --docker-server <your-acr-name.azurecr.io> --docker-email <your-email> --docker-username=<your-acr-name> --docker-password    <your-acr-password>  


#--> Get the Service Account by executing below command and update the  "serviceaccount.yml" file  
kubectl get serviceaccounts default -o yaml > ./serviceaccount.yml
update the "serviceaccount.yml" as below,
	#--> secrets:
	#-->	- name: hello-keda-secret
#--> Execute the below command to update serviceaccount, 
   > kubectl replace serviceaccount default -f ./serviceaccount.yml

#--> Update the "deploy.yaml" file with below lines and then deploy the Azure Function to AKS
#--> imagePullSecrets:
#--> 	- name: hello-keda-secret
 kubectl apply -f deploy.yaml

#--> Do some tests to check that the KEDA is working  correctly in AKS. First run the below command in PowerShell and ensure that you see '0' KEDA created pods in default namespace. 
 kubectl get pods

# Add few messages to the Queue in Azure Portal: "Home -> Resource groups -> $rg_name -> $storageaccname - Queues -> js-queue-items". Click "+ Add message"

#--> Verify in the PowerShell window new Pods are being created by running the below command and destroyed afterwards
kubectl get pods -w


# Cleanup Steps:
helm delete --purge keda
kubectl delete -f https://raw.githubusercontent.com/kedacore/keda/master/deploy/crds/keda.k8s.io_scaledobjects_crd.yaml
kubectl delete -f https://raw.githubusercontent.com/kedacore/keda/master/deploy/crds/keda.k8s.io_triggerauthentications_crd.yaml
kubectl delete -f deploy.yaml
kubectl delete deploy hello-keda
kubectl delete ScaledObject hello-keda
kubectl delete Secret hello-keda
