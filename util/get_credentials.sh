# Cluster #1  Advanced VNET
RESOURCE_GROUP_NAME=""
CLUSTER_NAME=""
LOCATION=eastus2
MC_RESOURCE_GROUP_NAME=""
SUBSCRIPTION_ID=""

# Cluster #2  Advanced VNET
RESOURCE_GROUP_NAME=""
CLUSTER_NAME=""
LOCATION=eastus
MC_RESOURCE_GROUP_NAME=""



# Get Credentials 
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME  --name $CLUSTER_NAME  --overwrite

# ClusterRoleBinding must be created before you can correctly access the dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard


