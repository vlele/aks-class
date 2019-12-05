# Get a disposable shell inside the AKS cluster
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il 
apt update
apt install wget
