CREATE TABLE ##RawData
(
	[FirstName]		NVARCHAR(4000)	NULL
	,[LastName]		NVARCHAR(4000)	NULL
	,[BirthDate]	DATETIME2(7)	NULL
	,[EMail]		NVARCHAR(4000)	NULL
	,[Civility]		NVARCHAR(4000)	NULL
)

BULK INSERT 
	##RawData
FROM
	N'C:\Windows\Temp\Data.csv'
WITH
(	
	FIELDTERMINATOR = '","'
	,ROWTERMINATOR = '"\n"'
	,CODEPAGE = 65001
	,FIRSTROW = 2
)
GO

UPDATE ##RawData SET Civility = SUBSTRING(Civility, 1, LEN(Civility) - 1) WHERE Civility LIKE '%"'

SELECT * FROM ##RawData

DROP TABLE ##RawData