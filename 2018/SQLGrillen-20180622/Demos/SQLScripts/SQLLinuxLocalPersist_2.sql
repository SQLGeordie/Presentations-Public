SET NOCOUNT ON;
USE [master];
DROP DATABASE IF EXISTS SQLGeordie;

RESTORE DATABASE SQLGeordie from disk = '/sqlserver/data/SQLGeordie.bak';

SELECT COUNT(*) AS [SQLLinuxLocalPersist2_NoOfRows]
FROM [SQLGeordie].[dbo].[SQLGeordietable];
GO