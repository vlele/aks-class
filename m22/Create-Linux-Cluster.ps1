#Define Variables
$USERNAME = "Itesh.Simlai@appliedis.com"
$GROUPNAME="test-backup-restore" # Resource Group where resource will be deployed
$SUBSCRIPTION = "<Your-Subscription-Id>" # Subscription where resource will be deployed
$LOCATION="eastus" # Azure Region for you resources
$AKS_CLUSTER_NAME="cluster1" # Your AKS cluster name
$COUNT_OF_NODES="1" # How many nodes will be in your cluster
$NODE_POOL_NAME="nodepool1" # Name for your nodes pool
$K8S_VERSION="1.14.8" # Version of kubernetse in your cluster
$VM_SIZE="Standard_D2_v2" # Size for VM's in you cluster 
$CLUSTER_VNET_NAME="test-backup-vnet" # Vnet name which will be used for your cluster 
$CLUSTER_SUBNET_NAME="test-backup-sn" # Subnet name which will be used for your cluster
$ADMIN_USER="aisadmin001" # Local admin username on your cluster nodes
$AKS_SP_NAME = "clusteradmin22" # Service principal name for your cluster 

# Login to azure 
az login --username $USERNAME
# Select appropriate subsription
az account set --subscription $SUBSCRIPTION
# Create a resource group 
az group create --location $LOCATION --name $GROUPNAME
# Create virtual network for Kubernetes cluster
az network vnet create --name $CLUSTER_VNET_NAME --address-prefixes 10.0.0.0/8 --resource-group $GROUPNAME 
# Create a Subnet for Kubernetes nodes and pods
az network vnet subnet create --vnet-name $CLUSTER_VNET_NAME --address-prefixes 10.10.0.0/16 --name $CLUSTER_SUBNET_NAME --resource-group $GROUPNAME
# Select subnet ID and save it as variable
$VNET_SUBNET_ID = az network vnet subnet show --vnet-name $CLUSTER_VNET_NAME --name $CLUSTER_SUBNET_NAME --resource-group $GROUPNAME --query id
# Create a SP (Service principal used for authentication to Azure API) AAD application for AKS cluster and save password to a variable 
$AKS_SP_APP_PASSWORD = az ad sp create-for-rbac --skip-assignment --name $AKS_SP_NAME  --query 'password' --output tsv
# It typically takes some time while Azure service principal will be provisioned. So it better to wait few minutes and then go forward overwise you may expect some fails during the next steps
Sleep 120 
# Save recently create SP application Id as a variable 
$AKS_SP_APP_ID = az ad sp list --display-name $AKS_SP_NAME --query [0].appId --output tsv
# Get full id of resource group where our vNet sits
$VNET_GROUP_SCOPE = az group show --name $GROUPNAME --query id --output tsv
 
# Assign a Network Contributor role for AKS Service principal. Scope is a resource group where our vNet sits.
az role assignment create --assignee $AKS_SP_APP_ID --scope $VNET_GROUP_SCOPE --role "Network Contributor"

######## Create AKS cluster by providing the following values #########
# A resource group where your cluster will be deployed
# Name of you cluster
# Name of pool
# Selected VM size for your nodes
# Name of you cluster
# How many nodes will be in tyour cluster. 
# Set the kubernetes version
# Choose network plugin. Kubenet for basic networking and Azure for advanced
# Choose a Load balancer fot you AKS. Select between Basic and Standard
# Choose between VirtualMachineScaleSets or AvailabilitySet
# IP address (in CIDR notation) used as the Docker bridge IP address on nodes. This CIDR is tied to the number of containers on the node. Default of 172.17.0.1/16.
# ID of Nodes/Pods subnet      
# CIDR for Kubernetes services (Should not overlap with Nodes/Pods subnet or with Docker Bridge CIDR which have defaults 172.17.0.0/16)
# Kubernetes DNS service IP address must be an IP address from service-cidr range
# Use your own account to create on node VMs for SSH access instead of default azureuser
# The maximum number of pods available to be deployed on node
# Choose a network policy for your AKS. Select between azure (Azure’s own implementation, called Azure Network Policies) and calico an open-source network and network security solution founded by Tigera
# Service principal used for authentication to Azure API
# Secret associated with the service principal. This argument is required if --service-principal is specified.
# Adding more logging
	  
az aks create  -g $GROUPNAME -n $AKS_CLUSTER_NAME  --nodepool-name $NODE_POOL_NAME  --node-vm-size $VM_SIZE --node-count $COUNT_OF_NODES  -k $K8S_VERSION --network-plugin azure --load-balancer-sku standard    --docker-bridge-address 172.17.0.1/16   --vnet-subnet-id $VNET_SUBNET_ID   --service-cidr 10.20.0.0/16    --dns-service-ip 10.20.0.10  --admin-username $ADMIN_USER  --max-pods 40  --network-policy azure  --service-principal $AKS_SP_APP_ID    --client-secret $AKS_SP_APP_PASSWORD --generate-ssh-keys --verbose 

Echo "Your Kubernetes SP application $AKS_SP_NAME password is: $AKS_SP_APP_PASSWORD, save it for future purposes"