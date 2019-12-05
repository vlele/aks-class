 # *******************************************************************************************
 #    Objective: This module demonstrates the MONGO DB as a STATEFULSET in Kubernetes in Azure.
 # *******************************************************************************************
 
NAMESPACE="mongo"

# Create namespace "mongo" if not already existing
kubectl create namespace $NAMESPACE

kubectl apply -f manifests/mongo-configmap.yaml 
kubectl apply -f manifests/mongo-service.yaml 
kubectl apply -f manifests/mongo.yaml

#--> Browse Dashboard 
# Make sure that ClusterRoleBinding is created before accessing the dashboard
#  Goto get_credentials.sh 

az aks browse --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME

#--> Execute a shell command inside mongo-0 pod
kubectl exec -it mongo-0 ls

kubectl describe pod/mongo-0

kubectl cluster-info 

# Clean up (takes a while)
kubectl delete -f manifests/mongo-configmap.yaml 
kubectl delete -f manifests/mongo-service.yaml 
kubectl delete -f manifests/mongo.yaml
kubectl delete namespace $NAMESPACE
