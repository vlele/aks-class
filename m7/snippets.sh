# ***************************************************************************************
#     Objective: This module demonstrates the SIDECAR PATTERN 
# ***************************************************************************************

#--> Create namespace 'concepts' dev spaces if already not created
NAMESPACE="concepts"
kubectl create namespace $NAMESPACE

# Cleanup
# run cleanup at the bottom of this file

 # *****************************
 #   SIDECAR PATTERN
 # *****************************

#--> Create a pod with side car
kubectl apply -f manifests/side-car.yaml  

#--> Describe
kubectl describe pod pod-with-sidecar

#--> Port forward to Pod port 
kubectl port-forward pod-with-sidecar 8080:80

http://localhost:8080/app.txt 

# Connect to side-car pod
kubectl exec pod-with-sidecar -c sidecar-container -it bash
# cd /usr/share/nginx/html (mount path)

# Clean up 
kubectl delete namespace $NAMESPACE

