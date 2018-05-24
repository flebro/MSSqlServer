use [master]
go

if exists (select top(1) 1 from sys.databases where name = 'AddressBook')
begin
	--On passe la base en single user
	-- 'with rollback immediate' abandonne les transactions incompletes en cours et déconnecte les utilisateurs
	alter database [AddressBook] Set
		single_user with rollback immediate

	drop database [AddressBook]
end
go

create database [AddressBook]
on primary --Fichier de données
 (
	name=AddressBook_dat --Nom logique du fichier
	,filename='C:\Users\flebro\Documents\GitHub\mssql\MSSqlServer\AddressBook.mdf'
	,size=64mb
	,maxsize=2gb
 )
log on
(
	name=AddressBook_log --Nom logique du fichier
	,filename='C:\Users\flebro\Documents\GitHub\mssql\MSSqlServer\AddressBook.ldf'
	,size=64mb
	,maxsize=UNLIMITED --2TO pour les logs et 16TO pour les data
)
go

use [AddressBook]

/*
-> Chaînes ASCII (1 octet par caractère)
	CHAR(n) : Taille fixe, ajout du caractère de bourage ' ' pour combler l'espace. n >= 1 && <= 8000
	VARCHAR(n) : Taille variable. n >= 1 && <= 8000
	VARCHAR(MAX) : Limité à 2Go. A utiliser en connaissance de cause pour des raisons de perf. Préférer VACHAR(n)

-> Chaînes UNICODE (2 octets par caractère n >= 1 && <= 4000)
	NCHAR(n)
	NVACHAR(n)
	NVACHAR(MAX)

-> Valeurs numériques exactes
	TYNIINT : Entier sur 1 octet
	SMALLINT : 2 octets
	INT : 4 octets
	BIGINT : 8 octets
	NUMERIC(p,d) : DECIMAL(p,s)
	DECIMAL(p,s) : Décimal à virgule fixe de 5 à 17 octets)
					p désigne le nombre de chiffres total (entre 1 et 38, 18 par défaut)
					s désigne le nombre de décimales après la virgule (entre 0 et p)
	SMALLMONEY : Décimal monétaire sur 4 octets
	MONEY : Décimal monétaire sur 8 octets

-> Valeurs numériques approximatives
	FLOAT : Flotant de 4 à 8 octets
	REAL : foat de 4 octets

	DATE:  du 01/01/0001 au 31/12/9999
	DATETIME2(f) : f est le nom de chiffres après la seconde (de 0 à 7, 7 par défaut)
	DATETIMEOFFSET : Ajoute au DATETIME2(f) le fuseau horraire (10 octets)
	TIME(f) : f est le nom de chiffres après la seconde (de 0 à 7, 7 par défaut)

	SMALLDATETIME et DATETIME sont dépréciés et ne doivent plus être utilisé

	BIT : 1 bit
	BINARY(n) : données binaires de longueur fixe n >= 1 && <= 8000
	VARBINARY(n) : données binaires de longueur variable
	VARBINARY(MAX) : 2Go max

	HIERARCHYID : Type ssytème de longeur variable (type CLR)
					Représente une position dans une hierarchie
	UNIQUEIDENTIFIER : GUID sur 16 octets

	Types obsolètes : TEXT, NTEXT et IMAGE

*/
