##***************************************************************************************
## Objective: This module demos the Availability Zone(AZ) in AKS. It shows how to create a cluster and distribute the node components across AZs.  
#***************************************************************************************
## Pre-requisites:
#    - Azure CLI version 2.0.76 or later installed and configured
#    > Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
#    - Have a AKS Cluster running in Central US/East US 2/East US/France Central/North Europe/West US 2/West Europe/UK South/Japan East/Southeast Asia 
#    - Make sure you have latest Kubectl Client and Kubernetes version 1.13.5 or greater
#    - Provide the appropriate values for the parameters in the "Create-Linux-Cluster.ps1" script
#  Note: Network-based storage such as Azure Files should be used for stateful workloads
## Cleanup: Make sure cleanup steps has been run
	
   > cd ..\m23
#--> Create an AKS cluster across availability zones
   > .\Create-Linux-Cluster.ps1
   > az aks get-credentials -g test-avaiability-zones-rg -n cluster1  --overwrite     
#--> Verify the nodes are spread across AZs. Please note that the label "failure-domain.beta.kubernetes.io/zone" is automatically assigned by AKS and  is used to create affinity rules 
   > kubectl get nodes -l agentpool=nodepool1 --show-labels
#--> Create  "avail-zones" namespace
   > kubectl create namespace avail-zones
#--> Deploy an application using the Nginx image across AZs    
   > kubectl run az-test --image=nginx --replicas=6 -n avail-zones
   > kubectl get pods -l run=az-test -n avail-zones  -o wide 
#--> Deploy a 2 tier application, Backend needs to be deployed in AZs 1&2 only by using Node Affinity. Frontend pods needs to be next to Backend pods
#--> using Inter-Pod Affinity rules
   > kubectl apply -f .\backend.yaml -n avail-zones
   > kubectl apply -f .\frontend.yaml -n avail-zones

#--> Verify the placement of the pods from below. You can see the Frontend and Backend pods are placed in the ...vmss000001 and vmss000000 nodes only
   > kubectl get pods -l app=backend -n avail-zones -o wide  
   > kubectl get pods -l app=frontend -n avail-zones -o wide
   
#--> Get the Service IP Address and browse nginx url
   > kubectl get svc -l app=frontend  -n avail-zones

# Cleanup Steps:
   > kubectl delete namespace avail-zones
   > Delete the Cluster

