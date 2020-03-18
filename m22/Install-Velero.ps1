#Define Variables
$USERNAME = "Itesh.Simlai@appliedis.com" # User for authenticate in azure
$SUBSCRIPTION = "<Your-Subscription-Id>" # Subscription where resource will be deployed
$VELERO_RESOURCE_GROUP_NAME = "velero-rgp-backup" # Resource group where storage account will be created and used to store a backups
$VELERO_STORAGE_ACCOUNT_NAME = "veleroacc" # Storage account name for Velero backups 
$VELERO_BLOB_CONTAINER_NAME = "velero" # Blob container for Velero backups
$LOCATION = "eastus" # Azure region for your resources
$VELERO_SP_NAME = "adminvelero" # A name for Velero Azure AD service principal name
$AKS_RESOURCE_GROUP = "MC_test-backup-restore_cluster1_eastus" # Name of the auto-generated resource group that is created when you provision your cluster in Azure
 
# Login to Azure
az login --username $USERNAME
# Select appropriate subscription 
az account set --subscription $SUBSCRIPTION
# Create a resource group for Velero
az group create --location $LOCATION --name $VELERO_RESOURCE_GROUP_NAME
# Create Storage account for Velero
az storage account create --name $VELERO_STORAGE_ACCOUNT_NAME --resource-group $VELERO_RESOURCE_GROUP_NAME --location $LOCATION --kind StorageV2 --sku Standard_LRS --encryption-services blob --https-only true --access-tier Hot
# Create a storage blob container 
az storage container create --name $VELERO_BLOB_CONTAINER_NAME --public-access off --account-name $VELERO_STORAGE_ACCOUNT_NAME
# Create Azure AD service principal with contributor role for Velero and query it's password to a variable
$VELERO_SP_APP_PASSWORD = az ad sp create-for-rbac --name $VELERO_SP_NAME --role "Contributor" --query 'password' --output tsv
# Save Velero service principal application ID to a variable
$VELERO_SP_APP_ID =  az ad sp list --display-name $VELERO_SP_NAME --query [0].appId --output tsv
# Save Subscription ID as a variable
$SUBSCRIPTION_ID = az account show --subscription $SUBSCRIPTION --query id --output tsv
# Save Tenant ID as a variable
$SUBSCRIPTION_TENANT_ID = az account show --subscription $SUBSCRIPTION --query tenantId --output tsv
 
# Create a credentials file for Velero
Echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID" >> credentials-velero
Echo "AZURE_TENANT_ID=$SUBSCRIPTION_TENANT_ID" >> credentials-velero
Echo "AZURE_CLIENT_ID=$VELERO_SP_APP_ID" >> credentials-velero
Echo "AZURE_CLIENT_SECRET=$VELERO_SP_APP_PASSWORD" >> credentials-velero
Echo "AZURE_RESOURCE_GROUP=$AKS_RESOURCE_GROUP" >> credentials-velero
Echo "Warning!!!"
Echo "*** Before proceeding further please make sure that the file 'credentials-velero' is in UTF-8 ***" 
timeout /t -1
 
# Install Velero on your AKS cluster.
velero install --provider azure --bucket $VELERO_BLOB_CONTAINER_NAME --secret-file ./credentials-velero --backup-location-config resourceGroup=$VELERO_RESOURCE_GROUP_NAME,storageAccount=$VELERO_STORAGE_ACCOUNT_NAME --snapshot-location-config apiTimeout="5m",resourceGroup=$VELERO_RESOURCE_GROUP_NAME,subscriptionId=$SUBSCRIPTION_ID --plugins velero/velero-plugin-for-microsoft-azure:v1.0.0