#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Windows\SQLWinExpDemoAttach\"
    #C:\Docker\Powershell\Functions\Demo-Setup.ps1 "C:\Docker\SQLServer\Windows\"
#### End Setup

cls
docker images
docker ps -a 

$DockerImageName = "sqlwinexpdemoattach"
$ContainerName = "SQLWinExpLocal"

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName

docker images
docker ps -a 

#Build the image using the DockerFileImage
docker build -t $DockerImageName .

docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1'--name $ContainerName -d -i -p 15571:1433 -d $DockerImageName

docker exec -it SQLWinExpLocal sqlcmd

docker logs $ContainerName 

docker inspect $ContainerName

docker ps -a 
docker start $ContainerName
docker stop $ContainerName
docker start $ContainerName

#Cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

