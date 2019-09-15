#start SQL Server, start the script to create the DB and import the data
/opt/mssql/bin/sqlservr & /usr/src/sqlscript/callcreatedocker2dbscript.sh & /usr/src/sqlscript/bash.sh