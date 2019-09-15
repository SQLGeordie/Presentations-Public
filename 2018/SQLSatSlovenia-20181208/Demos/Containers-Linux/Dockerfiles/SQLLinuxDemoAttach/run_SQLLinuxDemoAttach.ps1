#### Setup Demo
fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoAttach\"
#C:\Docker\Powershell\Functions\Demo-Setup.ps1 "C:\Docker\SQLServer\Linux\"
#### End Setup

cls
docker images
docker ps -a 

$DockerFileImage = "sqllinuxdemoattach"
$ContainerName = "SQLLinuxLocal"

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerFileImage

docker images
docker ps -a 

#Build the image using the DockerFileImage
docker build -t $DockerFileImage .

docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
    --name $ContainerName -d -i -p 1433:1433 `
    $DockerFileImage

docker exec -it SQLLinuxLocal /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 #NOTE: No need for the port

docker exec -it SQLLinuxLocal /bin/bash 

docker logs $ContainerName 

docker inspect $ContainerName
ipconfig
docker ps -a 
docker start $ContainerName
docker stop $ContainerName
docker start $ContainerName

#Cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerFileImage
docker images