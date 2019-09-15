###################### Setup first container (Hello World!)

#Should have microsoft/nanoserver image
docker iamges

docker search nanoserver 

docker pull microsoft/nanoserver

#-i means interactive
docker run -it --name MyFirstContainerHW microsoft/nanoserver cmd 

powershell.exe Add-Content C:\helloworld.ps1 'Write-Host "Hello World"'

exit

docker ps -a

docker commit MyFirstContainerHW helloworld

docker images

# --rm removes the container straight away
docker run --rm helloworld powershell c:\helloworld.ps1 

##############################################################################