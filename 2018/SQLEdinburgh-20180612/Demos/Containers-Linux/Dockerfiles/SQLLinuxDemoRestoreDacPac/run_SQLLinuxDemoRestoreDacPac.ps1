##### NOTE
/opt/mssql/bin/sqlpackage has been removed :(
https://github.com/Microsoft/mssql-docker/issues/135
#####
#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoRestoreDacPac\"
    #C:\Docker\Powershell\Functions\Demo-Setup.ps1 "C:\Docker\SQLServer\Linux\"
#### End Setup

cls
docker images
docker ps -a 

$DockerImageName = "sqllinuxdockerfilerestoredacpac"
$ContainerName = "sqllinuxrestoredacpac"

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName

docker images
docker ps -a 

#Build the image using the Dockerfile
docker build -t $DockerImageName .

docker run -e "SA_PASSWORD=P@ssword1" -e "ACCEPT_EULA=Y" `
        --name $ContainerName -d -i -t -p 1433:1433 `
        $DockerImageName

# troubleshooting and cleanup 

docker logs $ContainerName 

docker inspect $ContainerName

docker ps -a 
docker start $ContainerName
docker stop $ContainerName
docker start $ContainerName

#Cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
