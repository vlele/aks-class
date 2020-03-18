# Initialize Parameters for PowerShell Command Window
echo "Login to Azure" 
az login

$env:az_subscription_id = "<Your-Subscription-Id>"
$env:rg = "aks-az-policy-rg"
$env:cn = "test-azaks-policy"
$env:location = "westeurope"
$env:namespace = "aks-az-policy"
$env:displayNamePolicy = "[Limited Preview]: [AKS] Ensure only allowed container images in AKS"

echo "set account to Subscription Id: $env:az_subscription_id"
az account set --subscription $env:az_subscription_id    

echo "Configuring default location as $env:location "
az configure --defaults location=$env:location

echo "Create Resource Group" 
$resourceGroupObject = az group create --location $env:location --name $env:rg

echo "Get Resource Group Id:"
$env:resourceGroupId = "/subscriptions/$env:az_subscription_id/resourceGroups/$env:rg"
echo "resourceGroupId: $env:resourceGroupId"
echo "az_subscription_id: $env:az_subscription_id"
echo "rg: $env:rg"
echo "cn: $env:cn"
echo "location: $env:location"
echo "namespace: $env:namespace"
echo "displayNamePolicy: $env:displayNamePolicy"


