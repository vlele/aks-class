#***************************************************************************************
# Objective Helm Charts
#***************************************************************************************

#clean
# Helm init
# helm list
# helm delete --purge promaks

#--> Go to m11 module directory
cd ..\m11

NAMESPACE="progk8access"

# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE

# Install the RBAC configuration for tiller so that it has the appropriate access, and initialize helm system:
kubectl create -f manifests/helm-rbac.yaml
helm init --service-account=tiller

# Create a new default workspace by enabling the add-on for our cluster:

az aks enable-addons -a monitoring -n $CLUSTER_NAME -g $RESOURCE_GROUP_NAME


# Once installed, we should be able to see that the monitoring agent has been installed in the kube-system namespace:
kubectl get ds omsagent --namespace=kube-system

# To view output, we need to use the Azure web portal:
#	- In the resource pane at the far left  select the "All Services" panel, and search for Kubernetes.
#	- Select the Kubernetes services, and then select your test cluster (myAKSCluster if you used the same name in the course).
#	- Select Monitoring, and we can sort through log and monitoring data from nodes to individual containers. 
# Note: It may take up to 15 minutes for data collection to be displayed as the services may need to synchronize first.

#Use Helm to install Prometheus.
helm install --name promaks --set server.persistentVolume.storageClass=default stable/prometheus

# Once Prometheus is installed, and once it completes it's launch process (which may take a few minutes), we can locally expose the Prometheus UI to look at some of the captured metrics.  We'll do this by forwarding the UI's port to our local machine as the UI application doesn't have any access control defined.

k get pods
# find the id of promaks-prometheus-server-
PROMETHEUS_SERVER_POD="promaks-prometheus-server-7b84b44949-5wgq6"

kubectl   port-forward $PROMETHEUS_SERVER_POD 9090

# Once the portforward is running, we can point a web browser at:
http://localhost:9090

# Look to see what metrics are being gathered.
> Copy the "container_cpu_usage_seconds_total" parameter --> paste it into the "Textbox" Prometheus UI --> click "Execute"

# And we can also generate a little load if we'd like:
kubectl apply -f manifests/hostname.yml

> Edit "curl.yaml" file for correct "namespace: progk8access". 
kubectl apply -f manifests/curl.yml
kubectl exec -it $(kubectl get pod -l app=curl -o jsonpath="{.items[0].metadata.name}") sh 
# At the command prompt inside the pod execute the below command
# curl -o - http://hostname/version/ 

# Cleanup Steps:
helm del --purge promaks
kubectl delete -f manifests/curl.yml
kubectl delete -f manifests/hostname.yml
az aks disable-addons --addons monitoring -n $CLUSTER_NAME -g $RESOURCE_GROUP_NAME 
kubectl delete namespace $NAMESPACE


