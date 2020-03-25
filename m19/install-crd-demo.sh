#--> Create a website-controller to make Website objects run a web server pod exposed through a Service which will watch the API server for the creation of Website objects and then create the Service and the web server Pod for each of them.
kubectl create -f manifests/website-controller.yaml

#--> Create a CustomResourceDefinition(CRD) object to make Kubernetes accept our custom Website resource instances
kubectl create -f manifests/website-crd.yaml

#--> Create an instance of custom resource - Website
kubectl create -f manifests/kubia-website.yaml