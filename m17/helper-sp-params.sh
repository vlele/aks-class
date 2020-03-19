# Build a RBAC-powered service principal
RBAC="$(az.cmd ad sp create-for-rbac -o json)"

# Get the Subscription ID for the Azure Account
AZURE_SUBSCRIPTION_ID="$(az.cmd account show --query id --out tsv)"

# Get the Tenant ID, Client ID, Client Secret and Service Principal Name from Azure.
AZURE_TENANT_ID="$(echo ${RBAC} | jq -r .tenant)"
AZURE_CLIENT_ID="$(echo ${RBAC} | jq -r .appId)"
AZURE_CLIENT_SECRET="$(echo ${RBAC} | jq -r .password)"
AZURE_SP_NAME="$(echo ${RBAC} | jq -r .name)"

echo $AZURE_SUBSCRIPTION_ID
echo $AZURE_TENANT_ID
echo $AZURE_CLIENT_ID
echo $AZURE_CLIENT_SECRET
echo $AZURE_SP_NAME