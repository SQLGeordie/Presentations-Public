IF NOT EXISTS (SELECT * from sys.databases where name = 'SQLLinuxDemoRestore')
RESTORE DATABASE [SQLLinuxDemoRestore] FROM  DISK = N'/usr/src/sqlscript/sqllinuxdemorestore.bak' 
WITH  FILE = 1,  MOVE N'SQLLinuxDemoRestore' TO N'/usr/src/sqlscript/SQLLinuxDemoRestore.mdf',  
MOVE N'SQLLinuxDemoRestore_log' TO N'/usr/src/sqlscript/SQLLinuxDemoRestore_log.ldf',  
NOUNLOAD,  STATS = 5
GO