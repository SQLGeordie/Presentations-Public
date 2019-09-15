#wait for the SQL Server to come up
sleep 60

#run sqlpackage.exe script to publish the DB 
/opt/mssql/bin/sqlpackage /Action:Publish /SourceFile:/usr/src/sqlscript/Database1.dacpac /TargetDatabaseName:Database1 /TargetServerName:localhost /TargetUser:sa /TargetPassword:P@ssword1