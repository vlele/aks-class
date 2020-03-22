helm fetch --untar svc-cat/catalog
sed -i 's|extensions/v1beta1|apps/v1|g' ./catalog/templates/apiserver-deployment.yaml
sed -i 's|extensions/v1beta1|apps/v1|g' ./catalog/templates/controller-manager-deployment.yaml
helm install ./catalog/ --name catalog --namespace catalog --set apiserver.storage.etcd.persistence.enabled=true --set apiserver.healthcheck.enabled=false --set controllerManager.healthcheck.enabled=false --set apiserver.verbosity=2 --set controllerManager.verbosity=2
