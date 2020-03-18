#Create the AKS Cluster which will be used for all the Demos in KEDA
#Please pay attention to the region and AKS version numbers. 

Param 
(    
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
	[String] 
	$location,
	
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
	[String] 
	$rg,
	
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
	[String] 
	$cn		
) 
IF ($location -eq 'help') {
	echo "This PS Script file is used for for creating an AKS Cluster.Execute '.\az-basic-cmd.bat' batch file first."
	echo "Example: .\create-azkeda-demo-cluster.ps1 <location>, <version>"
	echo "Please use location as 'East US'/'Central US'/'West US 2'/'West Europe'/'Canada Central'/'Canada East region'"
	echo "Please use version > 1.15.x"
}
else{
	$keda_storageacc_name="kedastorageacc"
	$keda_storage_queue_name="js-queue-items"
	$version="1.15.7"
	Write-Host "location: $location RG: $rg keda_storageacc_name: $keda_storageacc_name keda_storage_queue_name: $keda_storage_queue_name version: $version"
	#--> Create a RG
	az group create --location $location --name $rg
	# Create Storage account for Velero
	az storage account create --name $keda_storageacc_name --resource-group $rg --location $location --kind StorageV2 --sku Standard_LRS --encryption-services blob --https-only true --access-tier Cool
	$storKey = az storage account keys list -g $rg  -n $keda_storageacc_name --query [0].value -o tsv
	$storConnStr = az storage account show-connection-string -g $rg -n $keda_storageacc_name --query connectionString  -o tsv
	# Create a storage blob container 
	az storage queue create --name $keda_storage_queue_name --account-name $keda_storageacc_name --account-name $storKey --connection-string $storConnStr
	#--> Create a AKS cluster
	az aks create -g $rg -n $cn --location $location --kubernetes-version $version --node-count 1 --enable-addons http_application_routing --generate-ssh-keys

	timeout /t 60

	#--> Get the credentials. 
	az aks get-credentials --resource-group $rg --name $cn --overwrite

	#--> Make sure the istio pods are running
	kubectl get pods -o wide --all-namespaces

	#--> Wait for 60 secs before launcing the Dashboard
	timeout /t 60

	#--> The following two commands are optional step to open Kubernetes Dashboard
	kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
	az aks browse --resource-group $rg --name $cn

	#--> Set Binding as needed ... 
	kubectl create clusterrolebinding itesh-cluster-admin-binding --clusterrole=cluster-admin --user=itesh
	kubectl create clusterrolebinding vlele-cluster-admin-binding --clusterrole=cluster-admin --user=vlele
}