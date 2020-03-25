# Create and set context to "$namespace" namespace
echo " Using $NAMESPACE namespace"

# Set context to "$namespace" namespace
kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE
# Use the context
kubectl config use-context $(kubectl config current-context)

#--> Create a ServiceAccount for the Website controller Deployment
echo "Create a ServiceAccount for the Website controller Deployment"
kubectl create serviceaccount website-controller
echo
#--> Create a ClusterRoleBinding to bind the website-controller ServiceAccount to the cluster-admin ClusterRole
echo "Create a ClusterRoleBinding to bind the website-controller ServiceAccount to the cluster-admin ClusterRole"
kubectl create clusterrolebinding website-controller  --clusterrole=cluster-admin --serviceaccount=default:website-controller
echo 

#--> Configure Helm to use the tiller service account
#echo "Configure Helm to use the tiller service account"
#helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
echo 
#helm repo update

#--> Applying Bug Fix
sed -i 's|apps/v1beta1|apps/v1|g' ./manifests/website-controller.yaml
sed -i 's|  template:|  selector:\n    matchLabels:\n      app: website-controller\n  template: |g' ./manifests/website-controller.yaml

