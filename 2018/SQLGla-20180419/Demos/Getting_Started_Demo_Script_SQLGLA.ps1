###################### Getting Setup 

# Enable Hyper-V for Windows 10 (Moby VM)
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All

#Enable Nested Virtualisation for Windows 10, run from the host machine :)
.\Enable-NestedVm.ps1 "Win10_Docker_Demo"

Install Docker for Windows!

##############################################################################

###################### Setup for Demo's
if (!(test-path -PathType Container "C:\Docker\SQLServer\Linux")){
	new-item -ItemType Directory -path "C:\Docker\SQLServer\Linux" -Force | Out-NULL
}
sl C:\Docker\SQLServer\Linux


######################################################
### *** Run through Docker settings in systray *** ###
######################################################



###################### Checking docker running as service
#Get-Service docker #Windows Server 2016 only

docker version

docker info #Check the "OS Type" showing Linux

#Show the difference beween Windows and Linux
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon 

docker info #Check the "OS Type" showing windows

#Switch back to Linux
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

##############################################################################



###################### Initial commands

  Clear-Host
  
#Search
  docker search busybox #--no-trunc

#Pull image from registry
  docker pull busybox #Defaults to "latest" tag

#Check Images
  docker images

#Run - Show differences when applying a name  
    docker run busybox  
    docker run --name SQLGLABusyBox busybox 
   
#Check containers
    docker ps -a

#Remove Container (using ContainerId)
    docker rm 8
    docker rm SQLGLABusyBox

#Remove all containers 
    docker run busybox  
    docker run busybox 
    docker run busybox 
    
    docker ps -a 
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Size}}"
    
    $psformat = "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Size}}"
    docker ps -a --format $psformat
    
    docker rm     #65, eb, 61

    docker rm $(docker ps -a -q) -f
	<#
		-a All
		-q Quiet
		-f Force
	#>
    docker ps -a --format $psformat
    
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
    docker images
  docker rmi $(docker images "imagename*" -q) -f #Obviously be careful with removing images!
  docker rmi $(docker images -f dangling=true -q) -f
  
  docker images -f dangling=true

##############################################################################



###################### Setup first SQL Server container (Linux)

<# Check running Linux
Clear-Host
docker version
docker info

# Switch to Linux if not done so
#& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon
#>

docker images

docker search microsoft/mssql #--no-trunc
#docker pull microsoft/mssql-server-linux:latest 
docker pull sqlgeordie/sqlonlinuxdemo:demo # Use tagged version just to be safe!

<#
  -e = Environment variable
  -d = Detatched mode
  -i = For Interactive processes (ie. docker exec)
  -p = Assign Port
#>
Clear-Host
docker run 	-e "ACCEPT_EULA=Y" `
			-e "SA_PASSWORD=P@ssword1" `
			--cpus="2" `
			--name SQLLinuxLocal -d -i `
			-p 1433:1433  `
            sqlgeordie/sqlonlinuxdemo:demo

  docker ps -a --format $psformat
  docker logs SQLLinuxLocal
  docker inspect SQLLinuxLocal
  
#Run in terminal / powershell.exe
    docker exec -it SQLLinuxLocal /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 
	#Show SELECT @@version and SELECT name FROM sys.databases

    docker exec -it SQLLinuxLocal /bin/bash #navigate to sqlcmd 

    echo $SA_PASSWORD # WOWZA!!! 
	
	exit
###


*** Connect via SSMS / SQLOps ***

SELECT  
  SERVERPROPERTY('MachineName') AS ComputerName,
  SERVERPROPERTY('ServerName') AS InstanceName,  
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion,  
  SERVERPROPERTY('ProductLevel') AS ProductLevel;  

#cleanup
docker stop $(docker ps -a -q) #Clean(er) shutdown
docker rm $(docker ps -a -q) -f
  
##############################################################################



###################### Restore a database by mounting a Docker Volume
<#
    ******* NOTE: Showing this to highlight the error with mounting a volume!! *******
#>

docker ps -a --format $psformat
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

# Setup backup Files
  Get-ChildItem "C:\Docker\SQLServer\" #-Recurse
  #Create directories for backups to map to
  if (!(Test-Path "C:\Docker\SQLServer\Backups\SQLLinuxLocal\AdventureWorks2016CTP3.bak")) {
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
	--cpus="2" `
	--name SQLLinuxLocal -d -i `
	-p 1433:1433 `
	-v C:\Docker\SQLServer\Backups:/var/backups `
	-v C:\Docker\SQLServer\Linux\SQLLinuxLocal:/sqlserver/data/ `
    sqlgeordie/sqlonlinuxdemo:demo 
    
docker ps -a --format $psformat
docker logs SQLLinuxLocal #Takes about 20s to mount the volume

#docker copy other files if required
docker cp C:\Docker\SQLServer\Backups\DatabaseSample\Test123.mdf `
         SQLLinuxLocal:/var/backups/Test123.mdf

#Run in the terminal
docker exec -it SQLLinuxLocal /bin/bash
cd /var/backups


*** Restore DATABASE via SSMS ***
--NOTE: Cannot restore to volume as it cannot expand it...
USE [master]
RESTORE DATABASE [AdventureWorks2016CTP3] FROM  DISK = N'/var/backups/AdventureWorks2016CTP3.bak' WITH  FILE = 1,  
MOVE N'AdventureWorks2016CTP3_Data' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_Data.mdf',  
MOVE N'AdventureWorks2016CTP3_Log' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_Log.ldf',  
MOVE N'AdventureWorks2016CTP3_mod' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_mod',  NOUNLOAD,  STATS = 5
GO
USE [master]
GO
CREATE DATABASE [Test123] ON 
( FILENAME = N'/sqlserver/data/Test123.mdf' )
 FOR ATTACH_REBUILD_LOG
GO

*** The filesystem has changed meaning mounting doesnt work, see error when attaching above! ***

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) -f

##############################################################################



###################### Breaking SQL on Linux - deleting mdf files
<#

***Removed this demo as the filesystem has changed meaning mounting doesn't work ***

#>



###################### Docker Volumes Demo - As opposed to MOUNTING a volume

<#
	- Create Volume
	- Create / Backup DB
	- Restore to another
#>

#Clear volume
docker rm dummycontainer
docker volume rm sqldatavolume

#Create dummy container to define and copy backup file
    #Rubbish but the only way to copy stuff to it!!!
    docker container create --name dummycontainer -v sqldatavolume:/sqlserver/data/ sqlgeordie/sqlonlinuxdemo:demo
    docker ps -a
#Copy AdventureWorks or whatever you like ;)
    docker cp C:\Docker\SQLServer\Backups\AdventureWorks2016CTP3.bak dummycontainer:/sqlserver/data/AdventureWorks2016CTP3.bak
    docker volume ls
    docker rm dummycontainer

    docker inspect sqldatavolume

#Create first container
    docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        --name SQLLinuxLocalPersist -d -i `
        -p 1433:1433 `
        -v sqldatavolume:/sqlserver/data `
        sqlgeordie/sqlonlinuxdemo:demo

#Create second container
    docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        --name SQLLinuxLocalPersist2 -d -i `
        -p 15105:1433 `
        -v sqldatavolume:/sqlserver/data `
        sqlgeordie/sqlonlinuxdemo:demo

    docker ps -a --format $psformat
    docker logs SQLLinuxLocalPersist
    docker logs SQLLinuxLocalPersist2

#Show what is in the sqldatavolume and copy another file if desired
    docker exec -it SQLLinuxLocalPersist2 /bin/bash
    cd /sqlserver/data
    ls
    docker cp C:\Docker\SQLServer\Backups\test.txt SQLLinuxLocalPersist:/sqlserver/data/test.txt


************ tSQL
#create stuff on SQLLinuxLocalPersist
	xp_dirtree '/sqlserver/data',0,1

	create database SQLGeordie
	go
	use SQLGeordie;
	create table SQLGeordietable (id int)
	go
	insert into SQLGeordietable
	values(rand())
	go 100

	SELECT TOP (1000) [id]
	FROM [SQLGeordie].[dbo].[SQLGeordietable];

	backup database SQLGeordie to disk = '/sqlserver/data/SQLGeordie.bak' with init

	xp_dirtree '/sqlserver/data',0,1

	:connect localhost,15105 --ie. SQLLinuxLocalPersist2
    --Check to see if the backup from SQLLinuxLocalPersist exists
    xp_dirtree '/sqlserver/data',0,1

	restore database SQLGeordie from disk = '/sqlserver/data/SQLGeordie.bak'

	SELECT TOP (1000) [id]
	FROM [SQLGeordie].[dbo].[SQLGeordietable]
************

#Cleanup
docker rm $(docker ps -a -q) -f
docker volume rm sqldatavolume

##############################################################################


###################### Docker File Examples 
GO TO:
C:\Docker\Demos\Dockerfiles\SQLLinuxDemoRestoreAW
C:\Users\Chris\OneDrive\Work\Development\GitHub\docker\Presentations\Introduction to Containers\Demos\Containers-Linux\Dockerfiles\SQLLinuxDemoRestoreAW

##############################################################################
