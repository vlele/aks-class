#***************************************************************************************
## Objective: This module demonstrates the network policy in AKS. It creates a MySql Pod and a  MySql Client Pod. First we show 
#***************************************************************************************

NAMESPACE=mysqlhelm
kubectl create namespace $NAMESPACE
MYSQL_HELM_PACKAGE_NAME="my-release"

#note -  assuming this module is a continuation of m13 
#--> Go to m16 module directory

cd ../m16

# apply network policy
kubectl apply -f manifests/backend-policy-disallow.yaml

# switch to ubuntu ssh and reconnect to the my sql instance 

kubectl apply -f manifests/backend-policy-allow.yaml

# Cleanup Steps:
helm del --purge MYSQL_HELM_PACKAGE_NAME
kubectl delete namespace $NAMESPACE