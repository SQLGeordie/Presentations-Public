#### Setup Demo (copies files to this directory)
fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoRestoreAW_Squash\"
#### End Setup

<#
docker rmi sqllinuxdockerfilerestoreaw1
docker rmi sqllinuxdockerfilerestoreaw2
#>

docker images "sqllinuxdockerfilerestoreaw1"

#Build the image keeping the layers
docker build -t sqllinuxdockerfilerestoreaw1 .

docker history sqllinuxdockerfilerestoreaw1

#Remove image for next demo
docker rmi sqllinuxdockerfilerestoreaw1
docker images "sqllinuxdockerfilerestoreaw1"

#Build the image squashing the layers
docker build -t sqllinuxdockerfilerestoreaw2 . --squash

docker images "sqllinuxdockerfilerestoreaw2"

docker history sqllinuxdockerfilerestoreaw2


#NOTE: No sa password
docker run --name sqllinuxrestoreaw1 -d -t -p 15105:1433 sqllinuxdockerfilerestoreaw1
docker run --name sqllinuxrestoreaw2 -d -t -p 15105:1433 sqllinuxdockerfilerestoreaw2

docker exec -it sqllinuxrestoreaw1 /opt/mssql-tools/bin/sqlcmd -S localhost,15105 -U sa -P P@ssword1 -Q "SET NOCOUNT ON; SELECT @@version; SELECT name from sys.databases"
docker exec -it sqllinuxrestoreaw2 /opt/mssql-tools/bin/sqlcmd -S localhost,15105 -U sa -P P@ssword1 -Q "SET NOCOUNT ON; SELECT @@version; SELECT name from sys.databases"
