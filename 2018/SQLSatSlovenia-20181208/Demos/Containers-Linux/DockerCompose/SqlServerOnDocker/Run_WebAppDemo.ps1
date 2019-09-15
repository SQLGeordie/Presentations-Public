#### Setup Demo
	fnDemoSetup "C:\Docker\SQLServer\Linux\SqlServerOnDocker\"
#### End Setup

docker ps -a

#docker-compose run web python3 manage.py migrate #10seconds
#docker-compose run web python3 manage.py createsuperuser
sl C:\Docker\SQLServer\Linux\SqlServerOnDocker\
docker-compose up web

cls
docker ps -a --format $psformat

docker exec -it sqlserverondocker_db_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Alaska2017 -Q "
			SET NOCOUNT ON;			
			SELECT convert(varchar,[date_joined],100),[username]
			FROM [master].[dbo].[auth_user]
			GO"

#Check "test" group created
docker exec -it sqlserverondocker_db_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Alaska2017 -Q "
			SET NOCOUNT ON;			
			SELECT [id],[name]
			FROM [master].[dbo].[auth_group]
			GO"
			
docker exec -it sqlserverondocker_db_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Alaska2017 -Q "
			SET NOCOUNT ON;			
			SELECT [id],[group_id],[permission_id]
  			FROM [master].[dbo].[auth_group_permissions]
			GO"

#Cleanup
docker rm $(docker ps -a -q) -f
