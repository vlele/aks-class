##***************************************************************************************
## Objective: This module demos the backup-restore  in AKS.  
#***************************************************************************************
## Pre-requisites:
#    - Make sure you have latest Kubectl Client
#    - Provide the values of the following parameters in the "Install-Velero.ps1" script
#    - Install Velero by downloading a command-line utility as shown below:
#	    - Download and install "velero-v1.2.0-windows-amd64.tar.gz" and unpack it 
#		- Add the location of the "velero.exe" to the Path environment variable
#		  Download Link: https://github.com/vmware-tanzu/velero/releases/tag/v1.2.0
## Cleanup: Make sure cleanup steps has been run

cd ..\m22

#--> Update the below script with appropriate values e.g., $GROUPNAME, $SUBSCRIPTION ... to create a Test Cluster
   > .\Create-Linux-Cluster.ps1
   > az aks get-credentials -g test-backup-restore -n cluster1  --overwrite     
#--> Update the below script with appropriate values e.g., $GROUPNAME, $SUBSCRIPTION ... to install Velero 
   > .\Install-Velero.ps1 
#--> Confirm that Velero has been successfully installed.       
   > kubectl get all -n velero  
   > kubectl logs deployment/velero -n velero
     
#--> *** Use Case: backup/restore stateful cluster***       
#--> Install nginx(with Persistence Volume) to namespace "nginx-example". This takes 2-3 mins time 
   > kubectl apply -f .\nginx-with-pv.yaml
   > kubectl get pvc,pods,service -n nginx-example
#--> See the page content shows "403 Forbidden". This is because default directory from where NGINX serves files is empty. because it’s our PVC disk  
   > Browse nginx url(http://<EXTERNAL-IP>)  
#--> Replace the nginx page by is uploading a file(index.html) from local machine to the Pod mounted Azure Disk.      
   > kubectl cp index.html nginx-example/nginx:/usr/share/nginx/html/index.html
   > Browse nginx url(http://<EXTERNAL-IP>) again and see the page content is as expected
   
#--> Take the Backup of the web site that we will restore later     
   > velero backup create cluster1-backup --include-namespaces nginx-example  
   > velero backup describe cluster1-backup   # The console display should show as "Phase:  Completed"
   > Verify the backup in Azure Portal : Home -> veleroacc - Containers -> velero -> backups -> cluster1-backup   
#--> Restore Backup: First delete nginx-example namespace by running:    
   > kubectl delete namespace  nginx-example
   > kubectl get all -n nginx-example
#--> Then execute Restore command and wait for 2-3 mins.    
   > velero restore create --from-backup cluster1-backup 
#--> The console display should show as "Phase:  Completed"
   > velero restore describe cluster1-backup-20200305130357
   > kubectl get pvc,pods,service -n nginx-example
#--> Wait for 4-5 mins. when the pod is running, browse nginx url again and see the updated page content is seen as before. May need to  hit F5  
   > Browse nginx url(http://<EXTERNAL-IP>)     
# Cleanup Steps:
   > kubectl delete namespace/velero clusterrolebinding/velero
   > kubectl delete crds -l component=velero
   > kubectl delete namespace  nginx-example   
   > Delete SP: Home --> Default Directory - App registrations --> Search and delete "adminvelero" & "clusteradmin22"
   > Delete the file created at local folder :  "credentials-velero"
   > Delete the Resource Groups:  "velero-rgp-backup" & "test-backup-restore"
