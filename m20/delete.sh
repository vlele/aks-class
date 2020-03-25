# Clean up:
kubectl delete -f manifests/storage-class-azure.yaml
kubectl delete -f manifests/persistent-volume-claim.yaml
kubectl delete -f manifests/pod.yaml
# Delete namespace
kubectl delete namespace $NAMESPACE