###################### Setup for Demo's

docker rm $(docker ps -a -q) -f

if (!(test-path -PathType Container "C:\Docker\SQLServer\Linux")){
	new-item -ItemType Directory -path "C:\Docker\SQLServer\Linux" -Force | Out-NULL
}
	sl C:\Docker\SQLServer\Linux

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

###################### End Setup

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




###################### Setup first SQL Server container (Linux)

#Check what images we have
	docker images

	docker search microsoft/mssql #--no-trunc
	#docker pull microsoft/mssql-server-linux:latest 
	docker pull sqlgeordie/sqlonlinuxdemo:demo # Use tagged version just to be safe!

	<#
	-e = Environment variable
	-d = Detatched mode
	-i = For Interactive processes (ie. echo test | docker run -i busybox cat)
	-p = Assign Port
	#>
Clear-Host
	docker run 	-e "ACCEPT_EULA=Y" `
				-e "SA_PASSWORD=P@ssword1" `
				--cpus="2" `
				--name SQLLinuxLocal -d `
				-p 1433:1433  `
        		sqlgeordie/sqlonlinuxdemo:demo
	
	docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Size}}"
    
    #$psformat = "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Size}}"
	
	docker ps -a --format $psformat
	
	docker logs SQLLinuxLocal
	
	docker inspect SQLLinuxLocal
  
#Run in terminal / powershell.exe
    docker exec -it SQLLinuxLocal /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 
	#Show SELECT @@version and SELECT name FROM sys.databases

#Check out how easy it is to get the sa password!
    echo $SA_PASSWORD # WOWZA!!! 
	
	exit
###

#cleanup
	docker stop $(docker ps -a -q) #Clean(er) shutdown
	docker rm $(docker ps -a -q) -f
  
##############################################################################



###################### Restore a database by mounting a Docker Volume
<#
    ******* NOTE: Showing this to highlight the error with mounting a volume!! *******
#>
	#Works
	docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
				--cpus="2" `
				--name SQLLinuxLocal -d `
				-p 1433:1433 `
				-v C:\Docker\SQLServer\Backups:/var/backups `
				sqlgeordie/sqlonlinuxdemo:demo 
	
	#Does not work (#This will fail due to 'NOTHING')
	docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
				--cpus="2" `
				--name SQLLinuxLocal2 -d `
				-p 15105:1433 `
				-v C:\Docker\SQLServer\Backups:/var/opt/mssql/data `
				sqlgeordie/sqlonlinuxdemo:demo 
		
	docker ps -a --format $psformat #10secs to fail
	docker logs SQLLinuxLocal2 #Takes about 20s to mount the volume

	docker exec -it SQLLinuxLocal /bin/bash
		cd /var/backups

*** The filesystem has changed meaning mounting doesnt work, see error when attaching above! ext2 / 3 to ext4***

#Clean up
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
	docker ps -a --format $psformat
	
#Copy AdventureWorks or whatever you like ;)
    docker cp C:\Docker\SQLServer\Backups\AdventureWorks2016CTP3.bak dummycontainer:/sqlserver/data/AdventureWorks2016CTP3.bak
    docker volume ls
    docker rm dummycontainer

    docker inspect sqldatavolume

	docker stop $(docker ps -a -q)
	docker rm $(docker ps -a -q) -f

#Create SQLLinuxLocalPersist container
    docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        		--name SQLLinuxLocalPersist -d `
        		-p 1433:1433 `
        		-v sqldatavolume:/sqlserver/data `
        		sqlgeordie/sqlonlinuxdemo:demo

#Create SQLLinuxLocalPersist2 container (NOTE the different port!)
    docker run 	-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=P@ssword1' `
        		--name SQLLinuxLocalPersist2 -d `
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

    docker exec -it SQLLinuxLocalPersist /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 -Q "
	SET NOCOUNT ON;
	USE [master];
    DROP DATABASE IF EXISTS SQLGeordie;

    exec xp_dirtree '/sqlserver/data',0,1

	CREATE DATABASE SQLGeordie;
    GO"
    
    docker exec -it SQLLinuxLocalPersist /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 -Q "
    DROP TABLE IF EXISTS [SQLGeordie].[dbo].[SQLGeordietable];
    CREATE TABLE [SQLGeordie].[dbo].[SQLGeordietable] (id int);
    GO"
    
    docker exec -it SQLLinuxLocalPersist /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 -Q "
	SET NOCOUNT ON;
	INSERT INTO [SQLGeordie].[dbo].[SQLGeordietable] (id)
	SELECT RAND()*1000 Random_Number
	GO 100"

    docker exec -it SQLLinuxLocalPersist /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 -Q "
	SET NOCOUNT ON;
	SELECT COUNT(*)
	FROM [SQLGeordie].[dbo].[SQLGeordietable];
    
	BACKUP DATABASE SQLGeordie to disk = '/sqlserver/data/SQLGeordie.bak' with init;

	EXEC xp_dirtree '/sqlserver/data',0,1
    GO"

    Clear-Host
    docker exec -it SQLLinuxLocalPersist2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 -Q "
	SET NOCOUNT ON;
	USE [master];
    DROP DATABASE IF EXISTS SQLGeordie;
    EXEC xp_dirtree '/sqlserver/data',0,1;

	RESTORE DATABASE SQLGeordie from disk = '/sqlserver/data/SQLGeordie.bak';

	SELECT COUNT(*)
	FROM [SQLGeordie].[dbo].[SQLGeordietable];
    GO"


    
#Cleanup
	docker rm $(docker ps -a -q) -f
	docker volume rm sqldatavolume

##############################################################################
