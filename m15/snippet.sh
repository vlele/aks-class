#***************************************************************************************
##  Objective: This module demonstrates the usage of Azure Identity 
#***************************************************************************************

#--> Go to m15 module directory
cd ../m15

NAMESPACE="aadpodidentity"
AAD_NAME="vl-demo-aad"

# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE

# 1. Create the Deployment, AAD Pod Identity consists of the Managed Identity Controller (MIC) deployment, the Node Managed Identity (NMI) daemon set, and several standard and custom resources
kubectl apply -f manifests/infra/deployment-rbac.yaml

# 2. Create an Azure Identity
PrincipalId=$(az identity create --name $AAD_NAME --resource-group $MC_RESOURCE_GROUP_NAME --query 'principalId' -o tsv)
echo $PrincipalId

#3 check if az identity got created 
az identity list

# Wait for some time(2-3 mins) and then execute the below command
az role assignment create --role Reader --assignee $PrincipalId --scope /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$MC_RESOURCE_GROUP_NAME

# 3. Pick up the “clientId” from the output of below command
az identity show -n $AAD_NAME -g $MC_RESOURCE_GROUP_NAME

# Edit the "manifests/demo/deployment.yaml" and "manifests/demo/aadpodidentity.yaml" files and provide "$client_id" copied from above step

# 4. Install the Azure Pod Identity, Binding and Deploy a Pod

kubectl apply -f manifests/demo/deployment.yaml

kubectl get pods

# 5. Check the Logs for the results: Below command will show the message on VMs: msg="succesfully made GET on instance metadata". "compute":{"location":"eastus","name":"<VM Name>","offer":"aks","osType":"Linux"
kubectl logs <demo-your-pod-specific>

# Cleanup Steps:
kubectl delete -f manifests/demo/aadpodidentity.yaml
kubectl delete -f manifests/demo/aadpodidentitybinding.yaml
kubectl delete -f manifests/demo/deployment.yaml

kubectl delete namespace $NAMESPACE

