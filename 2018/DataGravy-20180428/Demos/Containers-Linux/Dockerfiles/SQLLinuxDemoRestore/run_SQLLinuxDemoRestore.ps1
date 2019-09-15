#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoRestore\"
    #C:\Docker\Powershell\Functions\Demo-Setup.ps1 "C:\Docker\SQLServer\Linux\"
#### End Setup

cls
docker images
docker ps -a 

$DockerImageName = "sqllinuxdockerfilerestore"
$ContainerName = "sqllinuxrestore"

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
docker rm $(docker ps -a -q) -f
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
