helm fetch --untar azure/open-service-broker-azure
sed -i 's|extensions/v1beta1|apps/v1|g' ./open-service-broker-azure/templates/deployment.yaml
sed -i 's|extensions/v1beta1|apps/v1|g' ./open-service-broker-azure/charts/redis/templates/deployment.yaml
helm install ./open-service-broker-azure/ --name osba --namespace osba --set azure.subscriptionId=$AZURE_SUBSCRIPTION_ID --set azure.tenantId=$AZURE_TENANT_ID --set azure.clientId=$AZURE_CLIENT_ID --set azure.clientSecret=$AZURE_CLIENT_SECRET
