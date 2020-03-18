echo "**************************************************************"
$aks_preview_version=(az extension show --name aks-preview --query [version]  --out tsv)
echo "The aks-preview version is $aks_preview_version"

IF ($aks_preview_version -ne $null) {
echo "Update the extension to make sure you have the latest version installed. It's ok to be reported in red as 'No updates available for 'aks-preview'..."
az extension update --name aks-preview
}
IF ($aks_preview_version -eq $null) {

echo "Install the aks-preview extension to enable Preview Features E.g. Cluster Auto Scaler"
az extension add --name aks-preview
}

# az extension add --source https://aksvnodeextension.blob.core.windows.net/aks-virtual-node/aks_virtual_node-0.2.0-py2.py3-none-any.whl

ECHO "**************************************************************"
echo "**** Checking whether features for 'Microsoft.ContainerService/WindowsPreview' is already registered or not ****"
$aks_preview_registered=(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/WindowsPreview')].{State:properties.state}" --out tsv)
echo "'Microsoft.ContainerService/WindowsPreview' is $aks_preview_registered"

IF ($aks_preview_registered -ne "Registered") {
echo "**** Registering feature for 'Microsoft.ContainerService/WindowsPreview' . This takes around 6 mins to complete ... ****"
ECHO "When the registration state is Registered, press SPACE twice to exit timer. Then refresh the registration of the Microsoft.ContainerService resource provider."
az feature register --namespace Microsoft.ContainerService --name WindowsPreview
TIMEOUT /T 420 
}
ECHO "**************************************************************"
$container_instance = (Get-AzResourceProvider -ProviderNamespace Microsoft.ContainerInstance).RegistrationState[0]
echo "'Microsoft.ContainerInstance/WindowsPreview' provider is $container_instance"
IF ($container_instance -ne "Registered") {
echo "**** Registering providers e.g., 'Microsoft.ContainerInstance/WindowsPreview'. This takes around 2-3 mins to complete ...****"
ECHO "When the registration state is Registered, it's ok to press SPACE twice to exit timer."
az provider register -n Microsoft.ContainerInstance
ECHO "Checking the status of the ACI provider registration. The Namespace: Microsoft.ContainerService RegistrationState value is expected to be 'Registered'."
az provider list --query "[?namespace=='Microsoft.ContainerInstance']" -o tsv
TIMEOUT /T 120
}
ECHO "**************************************************************"
$policy_insights = (Get-AzResourceProvider -ProviderNamespace Microsoft.PolicyInsights).RegistrationState[0]
echo "'Microsoft.PolicyInsights/WindowsPreview' provider is $policy_insights"
IF ($policy_insights -ne "Registered") {
echo "**** Registering providers e.g., 'Microsoft.PolicyInsights'. This takes around 2-3 mins to complete ...****"
ECHO "When the registration state is Registered, it's ok to press SPACE twice to exit timer."
az provider register -n Microsoft.PolicyInsights
az provider list --query "[?namespace=='Microsoft.PolicyInsights']" -o tsv
TIMEOUT /T 120
}
ECHO "**************************************************************"
echo "**** Feature register(Microsoft.ContainerService/AKS-AzurePolicyAutoApprove)...****"
echo "**** Checking whether features for 'Microsoft.ContainerService/AKS-AzurePolicyAutoApprove' is already registered or not ****"
$aks_azpolicy_auto_approve=(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AzurePolicyAutoApprove')].{State:properties.state}" --out tsv)
echo "'Microsoft.ContainerService/AKS-AzurePolicyAutoApprove' is $aks_azpolicy_auto_approve"
IF ($aks_azpolicy_auto_approve -ne "Registered") {
ECHO "When the registration state is Registered, it's ok to press SPACE twice to exit timer."
az feature register --namespace Microsoft.ContainerService --name AKS-AzurePolicyAutoApprove
TIMEOUT /T 120
}
ECHO "**************************************************************"
echo "**** Feature register(Microsoft.PolicyInsights/AKS-DataPlaneAutoApprove)...****"
echo "**** Checking whether features for 'Microsoft.PolicyInsights/AKS-DataPlaneAutoApprove' is already registered or not ****"
$aks_data_plane_auto_approve=(az feature list -o table --query "[?contains(name, 'Microsoft.PolicyInsights/AKS-DataPlaneAutoApprove')].{State:properties.state}" --out tsv)
echo "'Microsoft.PolicyInsights/AKS-DataPlaneAutoApprove' is $aks_data_plane_auto_approve"
IF ($aks_data_plane_auto_approve -ne "Registered") {
# Feature register(PolicyInsights): Enable the add-on to the Azure Policy resource provider and confirm the feature is registered
az feature register --namespace Microsoft.PolicyInsights --name AKS-DataplaneAutoApprove

# Once the above shows 'Registered' run the following to propagate the update
az provider register -n Microsoft.PolicyInsights
# Once the above shows 'Registered' run the following to propagate the update
az provider register -n Microsoft.ContainerService
}
ECHO "**************************************************************"

$network = (Get-AzResourceProvider -ProviderNamespace Microsoft.Network).RegistrationState[0]
echo "'Microsoft.Network' provider is  $network"
IF ($network -ne "Registered") {
echo "**** Registering providers e.g., 'Microsoft.Network'. This takes around 2-3 mins to complete ...****"
ECHO "When the registration state is Registered, it's ok to press SPACE twice to exit timer."
az provider register -n Microsoft.Network
ECHO "Checking the status of the ACI provider registration. The Namespace: Microsoft.Network RegistrationState value is expected to be 'Registered'."
az provider list --query "[?namespace=='Microsoft.Network']" -o tsv
TIMEOUT /T 120
}

$storage = (Get-AzResourceProvider -ProviderNamespace Microsoft.Storage).RegistrationState[0]
echo "'Microsoft.Storage' provider is  $storage"
IF ($storage -ne "Registered") {
echo "**** Registering providers e.g., 'Microsoft.Storage'. This takes around 2-3 mins to complete ...****"
ECHO "When the registration state is Registered, it's ok to press SPACE twice to exit timer."
az provider register -n Microsoft.Storage
ECHO "Checking the status of the ACI provider registration. The Namespace: Microsoft.Storage RegistrationState value is expected to be 'Registered'."
az provider list --query "[?namespace=='Microsoft.Storage']" -o tsv
TIMEOUT /T 120
}

$compute = (Get-AzResourceProvider -ProviderNamespace Microsoft.Compute).RegistrationState[0]
echo "'Microsoft.Compute' provider is  $storage"
IF ($compute -ne "Registered") {
echo "**** Registering providers e.g., 'Microsoft.Compute'. This takes around 2-3 mins to complete ...****"
ECHO "When the registration state is Registered, it's ok to press SPACE twice to exit timer."
az provider register -n Microsoft.Compute
ECHO "Checking the status of the ACI provider registration. The Namespace: Microsoft.Compute RegistrationState value is expected to be 'Registered'."
az provider list --query "[?namespace=='Microsoft.Compute']" -o tsv
TIMEOUT /T 120
}
# az provider list --query "[?namespace=='Microsoft.ContainerInstance'].resourceTypes[] | [?resourceType=='managedClusters'].locations[]" -o tsv
ECHO "**************************************************************"

ECHO "Checking the Kubernetes Versions supported at Virtual Node supported location no. %location% "
az aks get-versions --query "orchestrators[].orchestratorVersion"

ECHO "**************************************************************"
ECHO "*******************End of Batch Execution**********************"