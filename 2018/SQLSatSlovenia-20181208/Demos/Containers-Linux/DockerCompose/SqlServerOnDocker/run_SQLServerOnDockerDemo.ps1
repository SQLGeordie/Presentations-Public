#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SqlServerOnDocker\"
    #C:\Docker\Powershell\Functions\Demo-Setup.ps1 "C:\Docker\SQLServer\Linux\"
#### End Setup

cls
docker images
docker ps -a 

#$DockerImageName = "SqlServerOnDocker"
$ContainerName = "sqlserverondocker"

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
docker rmi $DockerImageName

docker images
docker ps -a 

#Build the image using the Dockerfile
#docker build -t $DockerImageName .
#docker run -e "SA_PASSWORD=P@ssword1" -e "ACCEPT_EULA=Y" --name $ContainerName -d -i -t -p 1433:1433 $DockerImageName

docker-compose build db #to build db container
docker-compose run db sqlcmd -S localhost -U SA -P 'Alaska2017' #-Q 'create database docker2;'
#docker exec -it sqlserverondocker_db  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Alaska2017
	create database docker2
	go
docker-compose run web python3 manage.py migrate
docker-compose run web python3 manage.py createsuperuser
	Chris
	Password
	
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
