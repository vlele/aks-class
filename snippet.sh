#***************************************************************************************
## Objective: This module demonstrates the Flux CD. It creates a Sample Pod with version 1 image. Then version is changed to 2 in GIT.
#***************************************************************************************
## Prerequisites:
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#    - Chocolatey should be installed
## Assumptions: 
#	 	Assuming that the Cluster is already created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run	
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m16 module directory
cd ..\m26

$rg_name = "aks-class-new"
$cluster_name = "aks-class"
$location="eastus"
$namespace = "flux"
GHUSER="Vlele" 
# Create and set context to "$namespace" namespace
kubectl create namespace $namespace
kubectl config set-context $(kubectl config current-context) --namespace=$namespace
# Use the context
kubectl config use-context $(kubectl config current-context)

#--> # 1.Install Flux CD as per documentation "https://docs.fluxcd.io/en/1.18.0/references/fluxctl.html" for your environment. Below Chocolatey is used
choco install fluxctl
fluxctl install  --git-user=${GHUSER}  --git-email=${GHUSER}@users.noreply.github.com  --git-url=git@github.com:${GHUSER}/aks-class  --git-path=namespaces,workloads  --namespace=flux | kubectl apply -f -

#--> # 2.Wait for Flux to start
kubectl -n flux rollout status deployment/flux

#--> # 3.At startup Flux generates a SSH key and logs the public key. Find the SSH public key by installing fluxctl and running
fluxctl identity --k8s-fwd-ns $namespace
#--> # Output:
#--> # <Your-Deploy-Key>

#--> # 4.In order to sync your cluster state with git you need to copy the above Output(public key) and create a deploy key with write access on your GitHub repo
#--> # Browse  https://github.com/vlele/aks-class/settings/keys/new and enter the "Title" as "fluxcdkey", the above Key and check the checkbox "Allow write access"

#--> # 5.Deploy a sample pod through Git
$namespace = "prod"
# Create and set context to "prod" namespace
kubectl create namespace $namespace
# Create a K8S secret
kubectl create secret docker-registry taskapiacrsecret --docker-server vlakstest1b359.azurecr.io --docker-email vishwas.lele@appliedis.com --docker-username=vlakstest1b359 --docker-password  a0ahbi2+Ug7xIWSOEQaCbtKGdok0lROm --namespace $namespace
#--> # 5.Launch an Ubuntu pod
# Go to m1 folder ..\m1 
kubectl create -f manifests/pod.yaml --namespace $namespace

# Port forward local 8080 to port 80 on the pod (via the master)
kubectl port-forward m1pod 8080:80

# Bring up the swagger file 
http://localhost:8080/swagger

# Cleanup Steps:
kubectl delete namespace $namespace