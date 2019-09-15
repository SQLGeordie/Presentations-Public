sl "C:\Users\Chris\Documents\GitHub\docker\Presentations\Introduction to Containers\Demos\Dockerfiles\SQLLinuxDemoTagAndPush"
sl "C:\Users\Chris\SkyDrive\Work\Development\GitHub\docker\Presentations\Introduction to Containers\Demos\DockerImages"
#docker pull busybox
docker images

#docker save busybox > busybox.tar   #NOTE: This does not load!!!
                                    #Error processing tar file(exit status 1): archive/tar: invalid tar header
#Delete the file
    remove-item busybox.tar

#Do proper save    
    docker save --output=busybox.tar busybox #This does work :)
    docker rmi busybox
    docker images
    docker load --input busybox.tar