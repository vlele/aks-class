##***************************************************************************************
## Objective: This module demos the Ingress controller and DNS service in AKS. 
##***************************************************************************************

NAMESPACE=ingressdemo

# Create and set context to $namespace namespace
kubectl create namespace $NAMESPACE

# change the namespace

#--> Go to m9 module directory
cd ../m9

#enable addon http application routing 
# This enable the ingress controller and external DNS controller
az aks enable-addons --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --addons http_application_routing

# Then check to see what the root of our applications DNS will be. Run below command to get “cluster specific domain name”:
az aks show --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table

# Sample Result:
# -------------------------------------
#    1a29e9ff39e6416d9190.eastus.aksapp.io

# When we create an ingress and associate it with our application service, we will add the ingress name to this dns domain 
# to get our DNS 'pointer' back to our application.  e.g. if we create an ingress called hostname, then our new pointer will
# be: hostname.{DNS_root}

> Edit “hostname_ingress.yml” file with the above result in the line "- host: hostname.<CLUSTER_SPECIFIC_DNS_ZONE>" 
# e.g., “host: hostname.1a29e9ff39e6416d9190.eastus.aksapp.io” and execute below command to apply the ingress to our environment, 

kubectl apply -f manifests/hostname_ingress.yaml

# This can take several minutes 
# Open browser http://hostname.46c52f310834415dbc8f.eastus2.aksapp.io


# Clean Up:
k delete namespace $NAMESPACE

