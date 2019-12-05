NAMESPACE="test"

# Set context to $NAMESPACE
kubectl config set-context $(kubectl config current-context) --namespace=test

# Use the context
kubectl config use-context $(kubectl config current-context)

 # display list of contexts 
kubectl config get-contexts
                         
 # display current context
kubectl config current-context