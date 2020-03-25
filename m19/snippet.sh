##***************************************************************************************
## Objective: This module demonstrates the CustomResourceDefinition(CRD) object in AKS. We create object of type Website that contain nothing more than the website’s name and the source from which the website’s files (HTML, CSS, PNG, and others) should be obtained. We use a Git repository as the source of those files. When a user creates an instance of the Website resource, Kubernetes spins up a new web server pod and expose it through a Service. To achieve this, we create CustomResourceDefinitions for adding instances of a custom object and a Website controller that watches for Website objects and creates a Deployment and a Service.
##***************************************************************************************

#--> Go to m19 module directory
cd ../m19

NAMESPACE="default"

#--> Install CRD Demo pre-requisites
. install-crd-pre-requisites.sh

#--> Create a website-controller, CustomResourceDefinition(CRD) object and an instance of custom resource - Website 
. install-crd-demo.sh

#--> List all the websites in your cluster
kubectl get websites

#--> Retrieve full Website resource definition retrieved from the API server
kubectl get website kubia -o yaml

#-->  Get the Deployment, Service, and Pod created for the kubia-website
kubectl get deploy,svc,po

#-->  Display the logs of the Website controller
kubectl logs <Your-website-controller> -c main

#-->  Open a shell inside the "pod/kubia-website-xxxxxxxx-yyyyy" container("main") hosting the site
kubectl exec <Your-kubia-website-pod> -c main -it ash

#-->  Open a PowerShell window and pre-requisite to run "curl" command
apk add curl

#-->  Run "curl" command inside the container and check response. It should say "<html><body>Hello there.</body></html>"
curl http://<CLUSTER-IP>:80
exit

# Cleanup Steps:
. delete.sh
