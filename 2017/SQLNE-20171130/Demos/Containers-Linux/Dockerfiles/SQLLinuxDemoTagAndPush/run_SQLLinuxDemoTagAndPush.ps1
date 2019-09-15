<#
1 - Create a SQL on Linux container from Dockerfile (with tag v1.0
2 - The dockerfile will run a script to change the config of memory to 2048MB
3 - This will create a new image
4 - Tag the image with another version, ie. v1.1
5 - Push the image to Docker Hub
#>

#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoTagAndPush\"
	
    <#
	cls
    sl C:\
    $DockerLinuxDirectory = "C:\Docker\SQLServer\Linux\SQLLinuxDemoTagAndPush\"
    $DemoDirectory = $DockerLinuxDirectory
    #$DemoSourceFiles = split-path -parent $psISE.CurrentFile.Fullpath #Powershell ISE Only
	$context = [Microsoft.Powershell.EditorServices.Extensions.EditorContext]$psEditor.GetEditorContext() #VS Code
    $DemoSourceFiles = split-path -Parent $context.CurrentFile.Path
    if (Test-Path -PathType Container $DemoDirectory) {
        remove-item -Path $DemoDirectory -Force -Recurse | Out-NULL
        #new-item -ItemType Directory -Path $DemoDirectory -Force | Out-NULL
    }
    else {
        #new-item -ItemType Directory -Path $DemoDirectory -Force | Out-NULL
        }
    copy-item $DemoSourceFiles $DockerLinuxDirectory -Recurse
    
    Write-Host "Copying files from" $DemoSourceFiles "to" $DockerLinuxDirectory -ForegroundColor Green

    #Set the location to the Dockerfile
    sl $DemoDirectory
	#>
#### End Setup

docker images
docker ps -a 

$DockerImageName = "sqllinuxdockerfiletagandpush"
$ContainerName = "sqllinuxtagandpush"
$Repository = "sqlgeordie/sqlrepository"
$Tag = "tagtest"
$RepositoryForPush = $Repository+":"+$Tag

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName

docker images
docker ps -a 

#Build the image using the Dockerfile
docker build -t $DockerImageName .

docker run -e "SA_PASSWORD=P@ssword1" -e "ACCEPT_EULA=Y" --name $ContainerName -d -i -t -p 1433:1433 $DockerImageName

docker logs $ContainerName --tail "10"

#Now check the sql memory settings, give it 20s or so :)


#Now tag the image as a new version
docker images

docker tag $DockerImageName $RepositoryForPush

docker push $RepositoryForPush

#Drop the image and recreate
docker rmi $RepositoryForPush

docker images 
docker tag $DockerImageName $RepositoryForPush

docker push $RepositoryForPush #should already exist

#Cleanup
docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName -f
docker rmi $RepositoryForPush -f

#Dangling images
docker images -f dangling=true
docker rmi $(docker images -f dangling=true -q) -f