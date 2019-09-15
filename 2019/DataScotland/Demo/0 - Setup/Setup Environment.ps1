# Set Params
$newfolder="C:\K8sDemo\"
$sourcepath=~"\Git\Presentations\Docker\Kubernetify Your Containers\Data Scotland\Demo\"
$destination=$newfolder
# Create local folders
if (Test-Path $newfolder){
    Set-Location C:\
    remove-item -Path $newfolder
}
if (! (Test-Path $newfolder)){
    new-item -Path $newfolder -Type Directory
}

# Copy scripts
copy-item -Path $sourcepath -destination $destination -recurse -Force

# Change Directory
cd $destinationls

<###### MAKE SURE YOU HAVE WIFI ENABLED FOR MINIKUBE TO WORK #######>