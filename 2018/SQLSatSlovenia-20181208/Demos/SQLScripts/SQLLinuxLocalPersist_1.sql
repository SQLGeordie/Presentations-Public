SET NOCOUNT ON;
USE [master];
DROP DATABASE IF EXISTS SQLGeordie;

CREATE DATABASE SQLGeordie;
GO

DROP TABLE IF EXISTS [SQLGeordie].[dbo].[SQLGeordietable];
CREATE TABLE [SQLGeordie].[dbo].[SQLGeordietable] (id int);
GO

INSERT INTO [SQLGeordie].[dbo].[SQLGeordietable] (id)
SELECT RAND()*1000 Random_Number
GO 100

SELECT COUNT(*) AS [SQLLinuxLocalPersist_NoOfRows]
FROM [SQLGeordie].[dbo].[SQLGeordietable];

BACKUP DATABASE SQLGeordie to disk = '/sqlserver/data/SQLGeordie.bak' with init;

EXEC xp_dirtree '/sqlserver/data',0,1
GO