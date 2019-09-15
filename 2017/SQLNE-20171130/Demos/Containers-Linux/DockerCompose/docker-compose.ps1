#### Setup Demo
fnDemoSetup "C:\Docker\DockerCompose\Wordpress\"
   
    #Make DataVolume folder
    #New-Item -ItemType Directory DataVolume

#### End Setup

#Create the Containers for Wordpress and mariadb
docker-compose up -d

docker images

docker ps -a

#Wait ~30s
#Open Chrome, http://localhost:8085/


#Cleanup
docker rm $(docker ps -a -q) -f
docker volume rm $(docker volume ls -q)
