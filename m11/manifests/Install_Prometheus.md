To add metrics to our Kubernetes enviornment, we'll use Helm to install Prometheus.

Note: we've installed helm as a part of a previous chapter.

helm install --name promaks --set server.persistentVolume.storageClass=default stable/prometheus

Once Prometheus is installed, and once it completes it's launch process (which may take a few minutes), we can locally expose the Prometheus UI to look at some of the captured metircs.  We'll do this by forwarding the UI's port to our local machine as the UI application doesn't have any access control defined.

kubectl --namespace default port-forward $(kubectl get pods --namespace default -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}") 9090 &

Once the portforward is working, we can point a web browser at:

http://localhost:9090

look to see what metrics are being gathered.

container_cpu_usage_seconds_total

And we can also generate a little load if we'd like:

kubectl apply -f hostname.yml
kubectl apply -f curl.yml
kubectl exec -it $(kubectl get pod -l app=curl -o jsonpath={.items..metadata.name}) -- \
sh -c 'while [[ true ]]; do curl -o - http://hostname/version/ ; done'

