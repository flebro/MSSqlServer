use ImportBano
go

--drop view sqlviewbano
go

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_full
	(
	Identifier nvarchar(30) NULL,
	StreetNumber nvarchar(50) NULL,
	RoadName nvarchar(300) NULL,
	ZipCode nvarchar(30) NULL,
	CityName nvarchar(200) NULL,
	Source nvarchar(20) NULL,
	Latitude nvarchar(50) NULL,
	Longitude nvarchar(50) NULL,
	Id bigint NOT NULL IDENTITY (1, 1)
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_full SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_full OFF
GO
IF EXISTS(SELECT * FROM dbo.[full])
	 EXEC('INSERT INTO dbo.Tmp_full (Identifier, StreetNumber, RoadName, ZipCode, CityName, Source, Latitude, Longitude)
		SELECT Identifier, StreetNumber, RoadName, ZipCode, CityName, Source, Latitude, Longitude FROM dbo.[full] WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.[full]
GO
EXECUTE sp_rename N'dbo.Tmp_full', N'full', 'OBJECT' 
GO
COMMIT



alter table [Full] alter column Id BIGINT not null
go

create view SQLViewBano with schemabinding as
	select Id, Identifier, StreetNumber, RoadName, ZipCode, CityName, Latitude, Longitude,
	concat(StreetNumber + ', ', RoadName + ' - ', ZipCode + ' ', CityName) as AddrFull
	from dbo.[full]
go

create unique clustered index IX_SqlViewAddressId on dbo.SQLViewBano (id asc)
go

create fulltext catalog BanoCatalog
with accent_sensitivity = off
authorization [dbo]
go

create fulltext index on dbo.SQlviewbano (
	RoadName language 1036,
	CityName language 1036,
	AddrFull language 1036)
key index IX_SqlViewAddressId on banocatalog with stoplist off
go

select * from SQLViewBano where contains(RoadName, 'Pasteur')
go

if exists (select top(1) 1 from sys.procedures where name = 'SearchAddress')
begin
	drop procedure dbo.SearchAddress
end
go

create procedure dbo.SearchAddress @SearchString as nvarchar(4000)
as
begin
	declare @SearchCriteria nvarchar(4000);
	select TRIM(@SearchString)

end
go

select '''"' + STRING_AGG(TRIM(splited.value), ' AND ') +'*"''' from string_split('     test   ereree', ' ') as splited
 where splited.value <> ''
go

use ImportBano
go

drop fulltext catalog BanoCatalog
go

drop index  IX_SqlViewAddressId on dbo.SQLViewBano
go

drop fulltext index on  dbo.SQlviewbano
go

select * from sys.fulltext_indexes
go

dbcc shrinkfile(ImportBano_Log, 128)
go

use ImportBano
go
alter database ImportBano set recovery simple
with no_wait
dbcc shrinkfile(ImportBano_Log, 128)
go