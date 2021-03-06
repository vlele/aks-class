##***************************************************************************************
## Objective: This module demonstrates the cross cloud deployment in Kubernetes. Here we create a pod in both AKS and Google Cloud Platform Cluster and they both use same code.
## The pod uses a persistent volume claim which are generic but the storage classes they use are specific to the Platform. 
##***************************************************************************************

#--> Go to m20 module directory
cd ../m20

##***********************************Steps for the Azure Cloud****************************************************
NAMESPACE="crosscloud"

# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE

# Create the storage class
kubectl create -f manifests/storage-class-azure.yaml
# Create the persistent volume claim
kubectl create -f manifests/persistent-volume-claim.yaml
# Create the pod and associate with the persistent volume claim
kubectl create -f manifests/pod.yaml
# Show the "ClaimName:  cloud-storage-claim" is used in the pod and the corresonding PVC details shows "storage-provisioner: kubernetes.io/azure-disk"
kubectl describe pod mypod
kubectl describe pvc  cloud-storage-claim

# Clean up:
. delete.sh
##*****************************************************************************************************************

##***********************************Steps for the Google Cloud****************************************************
> Upload the "storage-class-gcp.yaml", "persistent-volume-claim.yaml" and "pod.yaml" files into the Google Cloud Platform
> Open the 
# Create the storage class
kubectl create -f storage-class-gcp.yaml
# Create the persistent volume claim
kubectl create -f persistent-volume-claim.yaml
# Create the pod and associate with the persistent volume claim
kubectl create -f pod.yaml

# Show the "ClaimName:  cloud-storage-claim" is used in the pod and the corresonding PVC details shows "storage-provisioner: kubernetes.io/gce-pd"
kubectl describe pod mypod
kubectl describe pvc  cloud-storage-claim

# Clean up:
kubectl delete -f storage-class-gcp.yaml
kubectl delete -f persistent-volume-claim.yaml
kubectl delete -f pod.yaml
##*****************************************************************************************************************
