# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE
echo 

# Set context to "$namespace" namespace
kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE
# Use the context
kubectl config use-context $(kubectl config current-context)

#--> Register providers needed for AKS cluster
echo "Register providers needed for AKS cluster: Microsoft.ContainerInstance and Microsoft.ContainerService"
az.cmd provider register -n Microsoft.ContainerInstance
az.cmd provider register -n Microsoft.ContainerService
echo 
#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
echo "A service account and role binding for use with Tiller was already created in m17. Skipping now."
#kubectl apply -f manifests/rbac-virtual-kubelet.yaml
echo 
#--> Check all pods in AKS cluster other than "kube-system" namespace
echo "Check all pods in AKS cluster other than 'kube-system' namespace"
kubectl get pods --all-namespaces --field-selector metadata.namespace!=kube-system
echo 
#--> Check all pods in AKS cluster in "kube-system" namespace
echo "Check all pods in AKS cluster in 'kube-system' namespace"
kubectl get pods --all-namespaces --field-selector metadata.namespace=kube-system
echo 

RESOURCE_GROUP_NAME="aks-class-new"
CLUSTER_NAME="aks-class"
echo "Using AKS cluster '$CLUSTER_NAME' in '$RESOURCE_GROUP_NAME'"
echo 

#--> Configure Helm to use the tiller service account
echo "Configure Helm to use the tiller service account"
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
echo 
helm repo update

