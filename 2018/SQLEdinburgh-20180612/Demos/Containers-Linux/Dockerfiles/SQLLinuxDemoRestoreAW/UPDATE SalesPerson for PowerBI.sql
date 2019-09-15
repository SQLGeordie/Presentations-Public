SELECT [BusinessEntityID]     
      ,[SalesYTD]     
FROM [AdventureWorks2016CTP3].[Sales].[SalesPerson]
WHERE BusinessEntityId = 274

UPDATE [AdventureWorks2016CTP3].[Sales].[SalesPerson]
SET [SalesYTD] = 10000000     
WHERE BusinessEntityId = 274

UPDATE [AdventureWorks2016CTP3].[Sales].[SalesPerson]
SET [SalesYTD] = 559697.5639     
WHERE BusinessEntityId = 274
