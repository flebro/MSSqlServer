DECLARE @BackupDirectoryPath AS NVARCHAR(4000)
DECLARE @BackupFilePath AS NVARCHAR(4000)
DECLARE @FileNameSufix AS NVARCHAR(20)

SET @BackupDirectoryPath = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\'

--DBName_YYYY_MM_DD_HHmm.bak
SELECT
	@FileNameSufix = CONCAT(	N'_', t0.CurrentYear, N'_', t0.CurrentMonth, N'_', t0.CurrentDay
			, N'_', t0.CurrentHour, t0.CurrentMinute, N'.bak')
FROM
(
	SELECT
		CAST(DATEPART(YEAR, GETDATE()) AS NVARCHAR(4))						AS CurrentYear
		,RIGHT( N'0' + CAST(DATEPART(MONTH, GETDATE()) AS NVARCHAR(2)), 2)	AS CurrentMonth
		,RIGHT( N'0' + CAST(DATEPART(DAY, GETDATE()) AS NVARCHAR(2)), 2)	AS CurrentDay
		,RIGHT( N'0' + CAST(DATEPART(HOUR, GETDATE()) AS NVARCHAR(2)), 2)	AS CurrentHour
		,RIGHT( N'0' + CAST(DATEPART(MINUTE, GETDATE()) AS NVARCHAR(2)), 2)	AS CurrentMinute
) AS t0

SET @BackupFilePath = CONCAT(@BackupDirectoryPath, N'AddressBook', @FileNameSufix)

--Sauvegarde de la base de données
BACKUP DATABASE [AddressBook] TO DISK = @BackupFilePath
	WITH 
		INIT
		,NAME = N'Sauvegarde complète de la base [AddressBook]'
		,SKIP
		,NOREWIND
		,NOUNLOAD
		,COMPRESSION
		,CHECKSUM
		,STATS = 10

--Vidage du fichier journal
GO
USE [AddressBook]

--Désactive le log
ALTER DATABASE [AddressBook] SET RECOVERY SIMPLE
GO
--Réduction du fichier de log à 1Mo
DBCC SHRINKFILE (AddressBook_log, 1)
GO
--Activation du log
ALTER DATABASE [AddressBook] SET RECOVERY FULL
GO

--Réduction du fichier de donnée
DBCC SHRINKFILE (AddressBook_dat, 1)