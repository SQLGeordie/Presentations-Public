#wait for the SQL Server to come up
sleep 20

#run the setup script to create the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P P@ssword1 -d master -i sqllinuxdemorestore.sql