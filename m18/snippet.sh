##***************************************************************************************
## Objective: This module demonstrates the VIRTUAL KUBELET ACI in AKS. 
##***************************************************************************************

#--> Go to m18 module directory
cd ../m18

NAMESPACE="aciaks"
#--> Install pre-requisites for ACI installation
. install-aci-pre-requisites.sh

#--> Install the ACI connector for linux OS type
install-aci-linux.sh

#--> List all nodes (notice the ACI nodes)
kubectl get nodes 

#--> Deploy pods into linux virtual kubelet
kubectl create -f manifests/virtual-kubelet-linux-hello-world.yaml
kubectl get pods -o wide
#--> Browse URL for "hello-world" application http://<ip> and see msg "Welcome to Azure Container Instances!" 
# Cleanup Steps:
helm del --purge virtual-kubelet
kubectl delete namespace $NAMESPACE
