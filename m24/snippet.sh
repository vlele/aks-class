##***************************************************************************************
## Objective: This module demos the cluster-upgrade-blue-green in AKS.  
#***************************************************************************************
## Pre-requisites:
#    - Azure CLI version 2.0.76 or later installed and configured. Use below command,
#      > Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
#    - Have an AKS Cluster running in Central US/East US 2/East US/France Central/North Europe/West US 2/West Europe/UK South/Japan East/Southeast Asia 
#    - Make sure you have latest Kubectl Client and Kubernetes version 1.13.5 or greater
#    - Provide the values of the following parameters in the "Create-Linux-Cluster.ps1" script
#  
## Cleanup: Make sure cleanup steps has been run
	
#--> Go to m24 module directory
> cd ..\m24
#--> Create  "avail-zones" namespace
> kubectl create namespace cluster-upgrade-bg
   
#--> Create an AKS cluster, "e.g.,: .\create-infrastructure-new.ps1 <username> <rg> <subscription> <location> <clustername> <nodecount> <k8s_version>"  
> .\Create-Linux-Cluster.ps1 "Itesh.Simlai@appliedis.com" "cluster-upgrade-blue-green-rg" "<Your-Subscription-Id>" "westeurope" "clust-upgrade" 1 "1.13.11"
> az aks get-credentials -g "cluster-upgrade-blue-green-rg" -n clust-upgrade  --overwrite
> kubectl get nodes
#--> Deploy the application and expose it using type loadbalancer
> kubectl apply  -f sample-app-v1.yaml
> kubectl apply -f sample-app-svc.yaml
> kubectl get pods -l app=sample-app-v1   
#--> Get the external IP for our app and browse http://<External IP>
> kubectl get svc sample-app-svc
#--> Check the K8S upgrades available 
> az aks get-upgrades -g "cluster-upgrade-blue-green-rg" -n clust-upgrade --output json    
#--> Using nodepools decouple the Control Plane upgrade from the nodes upgrade, 
> az aks upgrade -g "cluster-upgrade-blue-green-rg" -n clust-upgrade -k 1.14.8 --control-plane-only
> kubectl get nodes
#--> Add a new nodepool with the desired version "1.14.8"  
> az aks nodepool add  --resource-group "cluster-upgrade-blue-green-rg" --cluster-name clust-upgrade  --name node1418  --node-count 1  --node-vm-size "Standard_B2s" --kubernetes-version 1.14.8  
#--> See that a new nodepool  is added with the desired version "1.14.8"  
> kubectl get nodes
#--> Now open a new PowerShell Window and execute the below command to see how B/G works with nodepools approach
> do {(Invoke-WebRequest -Uri http://<External IP> -UseBasicParsing -DisableKeepAlive -Method head).StatusCode}while(1 -eq 1)
#--> Deploy sample-app-v2 application into new nodepool,
> kubectl apply -f sample-app-v2.yaml
> kubectl get pods -o wide
#--> When that all Pods are running above and see that the output in 2nd PowerShell Window prints 200 continuously after running below command
> kubectl delete -f sample-app-v1.yaml	

# Cleanup Steps:
> kubectl delete cluster-upgrade-bg
> Delete the Cluster if nedded

