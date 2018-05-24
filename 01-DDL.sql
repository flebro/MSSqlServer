use [master]
go

if exists (select top(1) 1 from sys.databases where name = 'AddressBook')
begin
	--On passe la base en single user
	-- 'with rollback immediate' abandonne les transactions incompletes en cours et d�connecte les utilisateurs
	alter database [AddressBook] Set
		single_user with rollback immediate

	drop database [AddressBook]
end
go

create database [AddressBook]
on primary --Fichier de donn�es
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
-> Cha�nes ASCII (1 octet par caract�re)
	CHAR(n) : Taille fixe, ajout du caract�re de bourage ' ' pour combler l'espace. n >= 1 && <= 8000
	VARCHAR(n) : Taille variable. n >= 1 && <= 8000
	VARCHAR(MAX) : Limit� � 2Go. A utiliser en connaissance de cause pour des raisons de perf. Pr�f�rer VACHAR(n)

-> Cha�nes UNICODE (2 octets par caract�re n >= 1 && <= 4000)
	NCHAR(n)
	NVACHAR(n)
	NVACHAR(MAX)

-> Valeurs num�riques exactes
	TYNIINT : Entier sur 1 octet
	SMALLINT : 2 octets
	INT : 4 octets
	BIGINT : 8 octets
	NUMERIC(p,d) : DECIMAL(p,s)
	DECIMAL(p,s) : D�cimal � virgule fixe de 5 � 17 octets)
					p d�signe le nombre de chiffres total (entre 1 et 38, 18 par d�faut)
					s d�signe le nombre de d�cimales apr�s la virgule (entre 0 et p)
	SMALLMONEY : D�cimal mon�taire sur 4 octets
	MONEY : D�cimal mon�taire sur 8 octets

-> Valeurs num�riques approximatives
	FLOAT : Flotant de 4 � 8 octets
	REAL : foat de 4 octets

	DATE:  du 01/01/0001 au 31/12/9999
	DATETIME2(f) : f est le nom de chiffres apr�s la seconde (de 0 � 7, 7 par d�faut)
	DATETIMEOFFSET : Ajoute au DATETIME2(f) le fuseau horraire (10 octets)
	TIME(f) : f est le nom de chiffres apr�s la seconde (de 0 � 7, 7 par d�faut)

	SMALLDATETIME et DATETIME sont d�pr�ci�s et ne doivent plus �tre utilis�

	BIT : 1 bit
	BINARY(n) : donn�es binaires de longueur fixe n >= 1 && <= 8000
	VARBINARY(n) : donn�es binaires de longueur variable
	VARBINARY(MAX) : 2Go max

	HIERARCHYID : Type ssyt�me de longeur variable (type CLR)
					Repr�sente une position dans une hierarchie
	UNIQUEIDENTIFIER : GUID sur 16 octets

	Types obsol�tes : TEXT, NTEXT et IMAGE

*/
