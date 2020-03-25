kubectl delete -f manifests/kubia-website.yaml
kubectl delete -f manifests/website-crd.yaml
kubectl delete -f manifests/website-controller.yaml
kubectl delete clusterrolebinding website-controller
kubectl delete serviceaccount website-controller
