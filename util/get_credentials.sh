# Cluster #1  Advanced VNET
RESOURCE_GROUP_NAME=vlakstest5_RG
CLUSTER_NAME=vlakstest5
LOCATION=eastus2
MC_RESOURCE_GROUP_NAME=MC_vlakstest5_RG_vlakstest5_eastus2
SUBSCRIPTION_ID=""

# Cluster #2  Advanced VNET
RESOURCE_GROUP_NAME=vlakstest5e_RG
CLUSTER_NAME=vlakstest5e
LOCATION=eastus
MC_RESOURCE_GROUP_NAME=MC_vlakstest5e_RG_vlakstest5e_eastus



# Get Credentials 
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME  --name $CLUSTER_NAME  --overwrite

# ClusterRoleBinding must be created before you can correctly access the dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard


