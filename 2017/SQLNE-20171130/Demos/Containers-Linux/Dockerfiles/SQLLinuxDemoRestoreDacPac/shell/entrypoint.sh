#start SQL Server, start the script to create the DB and import the data
/opt/mssql/bin/sqlservr & /usr/src/sqlscript/deploydacpac.sh & /usr/src/sqlscript/bash.sh
#/opt/mssql/bin/sqlservr.sh & /usr/src/sqlscript/import-data.sh &