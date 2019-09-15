FROM microsoft/mssql-server-windows-express

RUN powershell -Command (mkdir C:\\Docker\\SQLServer)

COPY AdventureWorks2012_Data.mdf C:\\Docker\\SQLServer
COPY AdventureWorks2012_log.ldf C:\\Docker\\SQLServer

ENV attach_dbs="[{'dbName':'AdventureWorks2012','dbFiles':['C:\\Docker\\SQLServer\\AdventureWorks2012_Data.mdf','C:\\Docker\\SQLServer\\AdventureWorks2012_log.ldf']}]"
