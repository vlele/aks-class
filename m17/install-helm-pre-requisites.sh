#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
echo "Create a service account and role binding for use with Tiller"
kubectl apply -f manifests/clusterrole-binding-sa.yaml
echo 
#--> Check all pods in AKS cluster other than "kube-system" namespace
echo "Check all pods in AKS cluster other than 'kube-system' namespace"
kubectl get pods --all-namespaces --field-selector metadata.namespace!=kube-system
echo 
#--> Check all pods in AKS cluster in "kube-system" namespace
echo "Check all pods in AKS cluster in 'kube-system' namespace"
kubectl get pods --all-namespaces --field-selector metadata.namespace=kube-system
echo 
#--> Configure Helm to use the tiller service account
echo "Configure Helm to use the tiller service account"
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
echo 
helm repo update

