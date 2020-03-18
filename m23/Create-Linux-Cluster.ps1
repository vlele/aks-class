# Define Variables
$username = "Itesh.Simlai@appliedis.com"
$rg="test-avaiability-zones-rg"
$subscription = "<Your-Subscription-Id>" 
$location="eastus" # Azure Region for you resources
$clustername="cluster1" # Your AKS cluster name
$nodecount="3" # How many nodes will be in your cluster
$k8s_version="1.14.8" # Version of kubernetse in your cluster
$vmsize="Standard_B2s" # Size for VM's in you cluster 
$sp_name = "tazclusteradmin" # Service principal name for your cluster 

# Login to azure 
az login --username $username
# Select appropriate subsription
az account set --subscription $subscription
# Create a resource group 
az group create --location $location --name $rg
# Create a SP (Service principal used for authentication to Azure API) AAD application for AKS cluster and save password to a variable 
$sp_pwd = az ad sp create-for-rbac --skip-assignment --name $sp_name  --query 'password' --output tsv
timeout /t  120 
# Save recently create SP application Id as a variable 
$sp_id = az ad sp list --display-name $sp_name --query [0].appId --output tsv
# Create the cluster
az aks create -g $rg -n $clustername --kubernetes-version $k8s_version --enable-vmss --load-balancer-sku standard --node-count $nodecount  --node-zones 1 2 3  --location $location  --node-vm-size $vmsize   --service-principal $sp_id --client-secret $sp_pwd --generate-ssh-keys --verbose 

echo "Service principal name for the cluster is $sp_name and password is  $sp_pwd. Save it for future purposes"