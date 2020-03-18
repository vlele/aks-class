Param 
(    
	[ValidateNotNullOrEmpty()] 
	$username = "Itesh.Simlai@appliedis.com",
	[ValidateNotNullOrEmpty()]																							
	$rg="cluster-upgrade-blue-green-rg",
	[ValidateNotNullOrEmpty()]
	$subscription = "<Your-Subscription-Id>" ,
	[ValidateNotNullOrEmpty()]
	$location="westeurope", 
	[ValidateNotNullOrEmpty()]
	$clustername="clust-upgrade", 
	[ValidateNotNullOrEmpty()]
	$nodecount="1", 
	[ValidateNotNullOrEmpty()]
	$k8s_version="1.13.11" 
) 
echo "User Name='$username' RG='$rg'  Subscription = $subscription, Location='$location', Clustername='$clustername', $nodecount = $nodecount, K8S version='$k8s_version' "

IF ($username -eq 'help') {
	echo "This PS Script file is used for creating  a AKS Cluster"
	echo "Example: .\create-infrastructure-new.ps1 <username> <rg> <subscription> <location> <clustername> <nodecount> <k8s_version>"
	echo "Please use location as 'westeurope'" 
	echo "Please use version > 1.13.X"
}
else{
	Write-Host "Performing Cluster Creation Operation for Demo Applications...."
	# Login to azure 
	az login --username $username
	# Select appropriate subscription
	az account set --subscription $subscription
	# Create a resource group 
	az group create --location $location --name $rg

	# Create the cluster
	az aks create -g $rg -n $clustername -k $k8s_version --enable-vmss --load-balancer-sku standard --node-count $nodecount  --location $location  --generate-ssh-keys --verbose 
}
