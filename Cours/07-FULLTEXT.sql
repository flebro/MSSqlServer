USE ImportBano
GO

IF NOT EXISTS (SELECT TOP(1) 1 FROM sys.columns AS t0 WHERE name = 'Id' AND t0.object_id = OBJECT_ID('Full'))
BEGIN
	ALTER TABLE [Full] ADD
		[Id] BIGINT NOT NULL IDENTITY
END
GO

IF EXISTS (SELECT TOP(1) 1 FROM sys.views WHERE name = 'SQLViewBano')
BEGIN
	DROP VIEW SQLViewBano
END
GO

CREATE VIEW SQLViewBano WITH SCHEMABINDING
AS
	SELECT
		t0.Identifier
		,t0.StreetNumber
		,t0.RoadName
		,t0.ZipCode
		,t0.CityName
		,t0.Latitude
		,t0.Longitude
	FROM
		[dbo].[Full] AS t0
GO

CREATE UNIQUE CLUSTERED INDEX [IX_SQLViewBanoIdentifier] ON [dbo].[SQLViewBano]
(
	[Identifier] ASC
)
GO