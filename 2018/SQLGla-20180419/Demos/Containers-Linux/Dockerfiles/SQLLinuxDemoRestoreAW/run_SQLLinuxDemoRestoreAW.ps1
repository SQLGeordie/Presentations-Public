#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoRestoreAW\"
    #C:\Docker\Powershell\Functions\Demo-Setup.ps1 "C:\Docker\SQLServer\Linux\"
#### End Setup

cls
docker images
docker ps -a 

$DockerImageName = "sqllinuxdockerfilerestoreaw"
$ContainerName = "sqllinuxrestoreaw"

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName

docker images
docker ps -a 

#Build the image using the Dockerfile
docker build -t $DockerImageName .

docker run -e "SA_PASSWORD=P@ssword1" -e "ACCEPT_EULA=Y" --name $ContainerName -d -i -t -p 1433:1433 $DockerImageName

docker logs $ContainerName 

docker inspect $ContainerName

docker ps -a 
docker start $ContainerName
docker stop $ContainerName
docker start $ContainerName

#Cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

docker rmi $DockerImageName

#docker volume ls
#docker build -t node-web-app .
#docker run -e ACCEPT_EULA=Y -e SA_PASSWORD=Yukon900 -p 1433:1433 -p 8080:8080 -d node-web-app