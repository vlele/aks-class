#--> Applying Bug Fix
sed -i 's|extensions/v1beta1|apps/v1|g' ./helmcharts/templates/deployment.yaml
sed -i 's|  template:|  selector:\n    matchLabels:\n      app: {{ template "fullname" . }}\n  template: |g' ./helmcharts/templates/deployment.yaml

sed -i 's|apps/v1beta1|apps/v1|g' ./manifests/virtual-kubelet-windows-phpiis-ltsc2016.yaml
sed -i 's|  template:|  selector:\n    matchLabels:\n      app: php-iislatest2\n  template: |g' ./manifests/virtual-kubelet-windows-phpiis-ltsc2016.yaml

#--> Install the ACI connector for Linux OS type using virtual-kubelet
echo "Install the ACI connector for  Linux OS type"
helm install ./helmcharts --name virtual-kubelet --namespace $NAMESPACE --set azure.subscriptionId=$AZURE_SUBSCRIPTION_ID --set azure.tenantId=$AZURE_TENANT_ID --set azure.clientId=$AZURE_CLIENT_ID --set azure.clientSecret=$AZURE_CLIENT_SECRET
echo 