#***************************************************************************************
## Objective: This module demonstrates the use of ServiceAccount, ClusterRole and ClusterRoleBinding to allow/disallow access to API Server from within a Pod in AKS 
#***************************************************************************************
#--> Go to m14 module directory
cd ../m14

# Create and set context to "$namespace" namespace
NAMESPACE=rbac-apiserver
kubectl create namespace $NAMESPACE

# change the default namespace

# Create a Service Account 
# 1. Execute the Command below to perform the following steps:
# 	- Create a custom service account foo
# 	- Create a role “service-reader” that only has read permissions on services resource 
# 	- Bind the “service-reader” role to foo
# 	- create a Pod with the custom service principle foo 

kubectl apply -f manifests/curl-custom-sa.yaml

# Open a bash shell inside the Pod
kubectl exec curl-custom-sa -c main -it bash

# 2. Execute the below Commands inside the pod and finally run an API command

token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
hostname=kubernetes.default.svc

curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/services
#   Note:  The output should contain HTTP/1.1 200 OK
  
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/secrets
#   Note:  The output should contain HTTP/1.1 200 OK
exit

#--> Illustrate the updated yaml with changed permissions

# 	- Original Line:  resources: ["services", "endpoints", "pods", "secrets"]
# 	- Updated Line:   resources: ["endpoints", "pods", "secrets"]  

kubectl apply -f manifests/curl-custom-sa.updated.yaml

# Open a bash shell inside the Pod
kubectl exec curl-custom-sa -c main -it bash

# 4. Execute the below Commands inside the pod and run an API command
token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
hostname=kubernetes.default.svc

#   Note:  The output should contain HTTP/1.1 403 Forbidden 
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/services
  
#   Note:  The output should contain HTTP/1.1 200 OK
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/secrets
exit

# Cleanup Steps:
kubectl delete namespace $NAMESPACE

