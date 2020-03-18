##***************************************************************************************
## Objective: This module demos the AKS and Azure Policy. In this demo we are going to create a policy that requires container images to come from a specific registry. This is a common use case to prevent the running of unauthorized containers in the cluster.
#***************************************************************************************
## Pre-requisites:
#  - Azure CLI version 2.0.76 or later installed and configured. Use below command,
#    > Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
#	 > az --version
#  - Have an AKS Cluster running in Central US/East US 2/East US/France Central/North Europe/West US 2/West Europe/UK South/Japan East/Southeast Asia 
#  - Make sure to have latest Kubectl Client and Kubernetes version 1.13.5 or greater
#  
## Cleanup: Make sure cleanup steps has been run


#--> -------------------------------------Do the following steps ahead of time and keep the cluster ready ---------------------------------------

> cd ..\m25
#--> Initialize the PowerShell parameters for command window
> .\initialize-powershell-parameters.ps1

#--> Install the pre-requisites  for the preview features
> .\az-basic-cmd.ps1

#--> Create an AKS cluster 
> az aks create -g $env:rg -l $env:location -n $env:cn --node-count 1 -k "1.15.7" --enable-vmss --load-balancer-sku standard --generate-ssh-keys --verbose 
> az aks get-credentials -g $env:rg -n $env:cn  --overwrite
#--> Create  "aks-az-policy" namespace
> kubectl create namespace $env:namespace
#--> Deploy a sample images before applying the policy and verify the pods 
> kubectl apply  -f pod-example.yaml -n $env:namespace
> kubectl get pods -n $env:namespace

#--> Install the Azure Policy Add-on in the AKS cluster using Azure Portal.
> In Portal:  Search "Kubernetes services" --> Select "test-azaks-policy" --> Policies (preview) --> Click "Enable add on" --> Wait for 2-3 mins
> kubectl get po -n kube-system  # This should show "azure-policy-xxxx-yyyy" pod running

#--> Create Assignment using Azure Portal.
> Go to https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definition --> click "Definitions" --> select "Definition Type=Policy","Type=Built-in", "Category=Kubernetes" --> Select "[Limited Preview]: [AKS] Ensure only allowed container images in AKS" from the filtered list of Built-in Policies 
> Click "Assign" on the top left, click "Scope" Ellipses(...) Button and choose "MSDN Azure Sponsorship" in Subscription and "aks-az-policy-rg" in Resource Group and click "Select"
> Click "Next" and enter the "^democncfarchacr.azurecr.io/.+$" into "Allowed container images regex" text box without quote marks and "Effect" as "EnforceRegoPolicy" --> Click "Review + Create"  --> "Create"
> Go to "Home --> Policy --> Assignments -->  Assignment Details" 
#--> Wait for 10-15 mins till you see the "Compliance state" "Assignment Details" in turns into "Non-compliant"


#--> -------------------------------------------Do the following steps at the time of demo -----------------------------------------------------
> kubectl delete  -f pod-example.yaml -n $env:namespace
> kubectl apply  -f pod-example.yaml -n $env:namespace
	Output:
	Error from server (["The operation was disallowed by policy ‘azurepolicy-containerallowedimages-b8859542b96752192949b3b2ed9683ce08085863a68b0cc73f29f8acc2d11b12’. Error details: container image \"gcr.io/kuar-demo/kuard-amd64:1\" is not allowed."]): error when creating "pod-example.yaml": admission webhook "gatekeeper.microsoft.com" denied the request: ["The operation was disallowed by policy ‘azurepolicy-containerallowedimages-b8859542b96752192949b3b2ed9683ce08085863a68b0cc73f29f8acc2d11b12’. Error details: container image \"gcr.io/kuar-demo/kuard-amd64:1\" is not allowed."]
> kubectl get pods -n $env:namespace
> Go to "Home --> Policy --> Assignments -->  [Limited Preview]: [AKS] Ensure only allowed container images in AKS -->  Parameters" and update the "Allowed container images regex" text box with "^democncfarchacr\.azurecr\.io\/.+$" and save
	
> kubectl apply  -f sample-app-v1_policy_compliant.yaml  -n $env:namespace
	Output:
	deployment.apps/sample-app-v1 created
> kubectl get pods -n $env:namespace  
> Go to "Home --> MC_aks-az-policy-rg_test-azaks-policy_westeurope --> Policy - Compliance" and see the "Compliance state" is "Non-compliant"
#--> Delete the deployment and redeploy the application with poicy compliance
> kubectl delete  -f sample-app-v1_policy_compliant.yaml -n $env:namespace  


# Cleanup Steps:
> kubectl delete namespace $env:namespace
> Disable addons from portal
> Remove Policy Assignment from portal

-------
#--> Below commands are supposed to work as per MS Doc but fails in Local&Cloud Shell
#--> Install the Azure Policy Add-on in the AKS cluster 
> az aks enable-addons --addons azure-policy  --name $env:cn --resource-group $env:rg  

#--> Create "[Limited Preview]: [AKS] Ensure only allowed container images in AKS" Policy 
> $policy = Get-AzPolicyDefinition | where-object {$_.Properties.displayName -eq $env:displayNamePolicy}
#--> Create Assignment by supplying "^democncfarchacr\.azurecr\.io\/.+$"
> New-AzPolicyAssignment -Name 'block-unknown-images-in-aks' -PolicyDefinition $policy -Scope $env:resourceGroupId 

