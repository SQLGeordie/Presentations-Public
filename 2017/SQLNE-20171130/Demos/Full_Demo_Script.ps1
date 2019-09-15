###################### Getting Setup 

# Enable Hyper-V for Windows 10 
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All

#Enable Nested Virtualisation for Windows 10
.\Enable-NestedVm.ps1 "Win10_Docker_Demo"
# & ".....\Development\GitHub\docker\Presentations\Introduction to Containers\Demos\Scripts\Enable-NestedVm.ps1" "Win10_Docker_Demo"

# NuGet is the package manager for the Microsoft development platform
# This is installed by the 2nd script so not needed
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force

# PowerShell module with commands for discovering, installing, and updating Docker images
Install-Module -Name DockerMsftProvider -Force

# Install package docker from the provide DockerMsftProvider (does not work on Win10)
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

Restart-Computer -Force

# Optional (Win 2016 only for Hyper-V containers)
Install-WindowsFeature –Name Hyper-V -ComputerName <computer_name> -IncludeManagementTools -Restart 

##############################################################################


###################### Checking docker running as service
if (!(test-path -PathType Container "C:\Docker\SQLServer\Linux")){
	new-item -ItemType Directory -path "C:\Docker\SQLServer\Linux" -Force | Out-NULL
}
sl C:\Docker\SQLServer\Linux

#Get-Service docker #Windows Server 2016 only

docker version

docker info #Check the "OS Type"

#Show the difference beween Windows and Linux
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon 

##############################################################################



###################### Initial commands

  Clear-Host
  
#Search
  docker search busybox #--no-trunc

#Pull
  docker pull busybox #Defaults to "latest" tag

#Check Images
  docker images

#Run  
  docker run --name SQLNEBusyBox busybox 
  docker run busybox 

#Check containers
  docker ps -a

#Remove Container (using ContainerId)
  docker rm SQLNEBusyBox

#Remove all containers 
  docker rm $(docker ps -a -q) -f

#Images
  Clear-Host
  docker images "busy*"
  docker images "microsoft/*" #Need the special character in the string!
  docker images "microsoft/*2017*"
  docker images "mic*/*:lat*"
  
#Dangling are "untagged" or "intemediatary" images and can be pruned
#Usually from an updated image from docker pull and rebuild image using dockerfile with that image used in FROM
  docker images -f dangling=true

#Remove Images
  docker rmi $(docker images "sql*" -q) -f #Only run this if there are images created by yourself starting with "sql"
  docker rmi $(docker images -f dangling=true -q) -f
  
##############################################################################



###################### Setup first SQL Server container (Linux)

#Check running Linux
Clear-Host
docker version
docker info

& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

docker images

docker search microsoft/mssql #--no-trunc
docker pull microsoft/mssql-server-linux:2017-GA # Use tagged version just to be safe!

<#
-e = Environment variable
-d = Detatched mode
-i = For Interactive processes (ie. docker exec)
-p = Assign Port
#>
Clear-Host
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=P@ssword1" `
  --cpus="2" --name SQLLinuxLocal -d -i -p 1433:1433  `
	microsoft/mssql-server-linux:2017-GA

  docker ps -a
  docker logs SQLLinuxLocal
  docker inspect SQLLinuxLocal
  
#Run in terminal / powershell.exe
    docker exec -it SQLLinuxLocal /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 #Show @@version and sys.databases

    docker exec -it SQLLinuxLocal /bin/bash #navigate to sqlcmd 

    echo $SA_PASSWORD # WOWZA!!! 
	
	exit
###

docker ps -a

docker inspect SQLLinuxLocal

***Connect via SSMS***

SELECT  
  SERVERPROPERTY('MachineName') AS ComputerName,
  SERVERPROPERTY('ServerName') AS InstanceName,  
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion,  
  SERVERPROPERTY('ProductLevel') AS ProductLevel;  

#cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
  
##############################################################################



###################### (Talk through) Hyper-V vs Windows Container (on Windows 2016 only)

*** Change use Windows 2016 as Win10 always uses HyperV ***
docker ps -a
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

docker run -d --name WinNanoNHV microsoft/nanoserver ping localhost -t
docker run -d --name WinNanoHV --isolation=hyperv microsoft/nanoserver ping localhost -t

#Run it against the host (#Check the PID on host machine, on Hyper-V it will be different to host)
get-process -Name ping 

#Run it against the Containers
docker exec -it WinNanoNHV powershell "get-process -Name ping"
docker exec -it WinNanoHV powershell "get-process -Name ping"


<#
ie.
	Host = 5628
	SQLExpLocalNHV = 5628
	SQLExpLocalHV = 1328	
#>

##### At this point you can show connecting from another machine #####
#Windows 10 to Windows 2016
ipconfig ==> 192.168.1.245
Spin up Container (without ping!)
Connect using 192.168.1.245,15433 ==> or whatever the port number is

#cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container

##############################################################################


###################### Restore a database using Docker Volumes

docker ps -a
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

# Setup backup Files
  Get-ChildItem "C:\Docker\SQLServer\"
  #Create directories for backups to map to
  if (!(Test-Path -PathType "C:\Docker\SQLServer\Backups\SQLLinuxLocal\AdventureWorks2016CTP3.bak")) {
    if (!(Test-Path -PathType Container "C:\Docker\SQLServer\Backups\SQLLinuxLocal")) {
      New-Item C:\Docker\SQLServer\Backups\SQLLinuxLocal -type directory | Out-NULL
    }
    if (!(Test-Path -PathType Container "C:\Docker\SQLServer\Linux\SQLLinuxLocal")) {
      New-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -type directory | Out-NULL
    }
    Copy-Item C:\Docker\SQLServer\Backups\AdventureWorks2016CTP3.bak C:\Docker\SQLServer\Backups\SQLLinuxLocal\AdventureWorks2016CTP3.bak
  }
  Get-ChildItem "C:\Docker\SQLServer\Backups\SQLLinuxLocal\"
# end setup files

docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
  --name SQLLinuxLocal -d -i -p 1433:1433 `
	-v C:\Docker\SQLServer\Backups:/var/backups `
	-v C:\Docker\SQLServer\Linux\SQLLinuxLocal:/var/opt/mssql `
	microsoft/mssql-server-linux:2017-GA

docker ps -a
docker logs SQLLinuxLocal

#Run in the terminal
docker exec -it SQLLinuxLocal /bin/bash
cd /var/backups


*** Restore DATABASE ***
USE [master]
RESTORE DATABASE [AdventureWorks2016CTP3] FROM  DISK = N'/var/backups/AdventureWorks2016CTP3.bak' WITH  FILE = 1,  
MOVE N'AdventureWorks2016CTP3_Data' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_Data.mdf',  
MOVE N'AdventureWorks2016CTP3_Log' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_Log.ldf',  
MOVE N'AdventureWorks2016CTP3_mod' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_mod',  NOUNLOAD,  STATS = 5
GO

*** Do not cleanup - need for next demo! ***

##############################################################################


###################### Breaking SQL on Linux - deleting mdf files

#Show the folders and files created
sl C:\Docker\SQLServer\Linux\SQLLinuxLocal\data
ls

#### Let's have some fun
#CREATE a Database
--TSQL
	CREATE DATABASE Test123;
	GO
	USE Test123;
	GO
*** Now delete the mdf and ldf files *** WOWZA!!! ***

Run scripts against the DB:
	SELECT * FROM sys.tables
	CREATE TABLE table1 (id int)

***Still works! *** 

docker stop SQLLinuxLocal
docker start SQLLinuxLocal
docker logs SQLLinuxLocal

Conect via SSMS

*** Recovery pending

*** Undo the delete (Ctrl-Z)
docker stop SQLLinuxLocal
docker start SQLLinuxLocal
docker logs SQLLinuxLocal

*** Connect again and should now work! ***

#cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
sl C:\Docker\SQLServer\Linux
Remove-Item C:\Docker\SQLServer\Backups\SQLLinuxLocal -Recurse
Remove-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -Recurse

##############################################################################



###################### (Talk through) Docker Copy and Attach (via script on SSMS) Example

docker ps -a
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

#Cleanup
Remove-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -Recurse
New-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -ItemType directory

docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        --name SQLLinuxLocal -d -i -p 1433:1433 `
        -v C:\Docker\SQLServer\Linux\SQLLinuxLocal:/var/opt/mssql `
        microsoft/mssql-server-linux

#docker copy
docker cp C:\Docker\SQLServer\Backups\DatabaseSample\ContainerDB.mdf `
         SQLLinuxLocal:/var/opt/mssql/data/ContainerDB.mdf

***Run on PowerShell.exe
docker exec -it SQLLinuxLocal bash
cd /var/opt/mssql/data
ls

USE [master]
GO
CREATE DATABASE [ContainerDB] ON 
( FILENAME = N'/var/opt/mssql/data/ContainerDB.mdf' )
 FOR ATTACH_REBUILD_LOG
GO

#Cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f
sl C:\Docker\SQLServer\Linux
Remove-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -Recurse
New-Item C:\Docker\SQLServer\Linux\SQLLinuxLocal -ItemType directory
##############################################################################

