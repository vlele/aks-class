##***************************************************************************************
## Objective: This module demonstrates the CustomResourceDefinition(CRD) object in AKS. We create object of type Website that contain nothing more than the website’s name and the source from which the website’s files (HTML, CSS, PNG, and others) should be obtained. We use a Git repository as the source of those files. When a user creates an instance of the Website resource, Kubernetes spins up a new web server pod and expose it through a Service. To achieve this, we create CustomResourceDefinitions for adding instances of a custom object and a Website controller that watches for Website objects and creates a Deployment and a Service.
##***************************************************************************************

#--> Go to m19 module directory
cd ../m19

NAMESPACE="default"

#--> Create a ServiceAccount for the Website controller Deployment
kubectl create serviceaccount website-controller

#--> Create a ClusterRoleBinding to bind the website-controller ServiceAccount to the cluster-admin ClusterRole
kubectl create clusterrolebinding website-controller  --clusterrole=cluster-admin --serviceaccount=default:website-controller

#--> Create a website-controller to make Website objects run a web server pod exposed through a Service which will watch the API server for the creation of Website objects and then create the Service and the web server Pod for each of them.
kubectl create -f manifests/website-controller.yaml

#--> Create a CustomResourceDefinition(CRD) object to make Kubernetes accept our custom Website resource instances
kubectl create -f manifests/website-crd.yaml

#--> Create an instance of custom resource - Website
kubectl create -f manifests/kubia-website.yaml

#--> List all the websites in your cluster
kubectl get websites

#--> Retrieve full Website resource definition retrieved from the API server
kubectl get website kubia -o yaml

#-->  Get the Deployment, Service, and Pod created for the kubia-website
kubectl get deploy,svc,po

#-->  Display the logs of the Website controller
kubectl logs <Your-website-controller> -c main


#-->  Open a shell inside the kubia-website container("main") hosting the site
kubectl exec kubia -c main -it ash

#-->  Install necessary components inside the container to run "curl" command
apk add curl

#-->  Run "curl" command inside the container and check response. It should say "<html><body>Hello there.</body></html>"
curl http://<CLUSTER-IP>:80
exit


# Cleanup Steps:
kubectl delete -f manifests/kubia-website.yaml
kubectl delete -f manifests/website-crd.yaml
kubectl delete -f manifests/website-controller.yaml
kubectl delete serviceaccount website-controller
kubectl delete  rs --all
