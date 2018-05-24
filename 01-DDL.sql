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
go
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

create table [AddressBook].dbo.City
(
	[Identifier] bigint not null identity,
	[Name] nvarchar(200) not null,
	[ZipCode] nvarchar(30) not null
)

create table [AddressBook].dbo.Civility
(
	[Identifier] bigint not null identity,
	[ShortName] nvarchar(5) not null,
	[Name] nvarchar(40) not null
)

create table [AddressBook].dbo.Contact
(
	[Identifier] bigint not null identity,
	[IdentifierCivility] BIGINT null,
	[FirstName] nvarchar(100) null,
	[LastName] nvarchar(100) not null,
	[BirthDate] date null,
	[EMail] nvarchar(100) null
)

create table [AddressBook].dbo.[Address]
(
	[Identifier] bigint not null identity,
	[IdentifierCity] BIGINT not null,
	[StreetNumber] nvarchar(10) null,
	[RoadType] nvarchar(50) null,
	[RoadName] nvarchar(300) not null,
	[Complement1] nvarchar(200) not null,
	[Complement2] nvarchar(200) not null,
	[Latitude] decimal(18,15) null,
	[Longitude] decimal(18,15) null
)

create table [AddressBook].dbo.[AddressContact]
(
	[Identifier] bigint not null identity,
	[IdentifierAddress] BIGINT not null,
	[IdentifierContact] BIGINT not null
)

go

alter table [Address] add [Code] nvarchar(30) null
go

update [Address] set [Code] = N'' where [Code] IS null
GO

alter table [Address] alter column Code nvarchar(30) not null;
go

alter table Address drop column Code
go

alter table [Address] add [Code] nvarchar(30) not null default N''
go

declare @sqlquery nvarchar(max);
--select
--	@sqlquery = STRING_AGG(N'ALTER TABLE [' + object_name(parent_object_id) + N'] DROP CONSTRAINT [' + name + N']', nCHAR(13))
--from sys.default_constraints

--exec sp_executesql @sqlquery

select
	@sqlquery = N'ALTER TABLE [' + object_name(parent_object_id) + N'] DROP CONSTRAINT [' + name + N']'
from sys.default_constraints
print @sqlquery
go

/*
Contraintes
	UNIQUE (UK)
	PRIMARY KEY (PK) Un index de type CLUSTERED est g�n�r� automatiquement
	FOREGIN KEY (FK) : Cl� �trang�re, permet de maintenir l'int�grit� referentielle
						Pas d'index g�n�r� automatiquement
	DEFAULT (DK) : Valeiur pa defaut
	CHECK (CK) Impose un domaine de valeurs ou une condition entre colonnes
	*/

alter table [City] add constraint PK_City_Identifier primary key (Identifier)
go

alter table [Civility] add constraint PK_Civility_Identifier primary key (Identifier)
go

alter table [Contact] add constraint PK_Contact_Identifier primary key (Identifier)
go

alter table [Address] add constraint PK_Address_Identifier primary key (Identifier)
go

alter table [AddressContact] add constraint PK_AddressContact_Identifier primary key (Identifier)
go

alter table AddressContact add constraint [UK_AddressContact_IdentifierAddress_IdentifierContact] UNIQUE([IdentifierAddress], [IdentifierContact]);
go

-- FK

/*
CASCADE: R�percute sur les enregistrements li�es
SET NULL: Donne la valeur NULL. Possible seulement si la colonne FK accepte le marqueur NULL
SET DEFAULT : Applique la valeur par d�faut. Possible seulement si la/les colonne(s) ont une contrainte DEFAULT
NO ACTION: (par d�faut) D�clenche une erreur si l'enregistrement est r�f�renc�es
*/

alter table [Address]
add constraint FK_Address_City_IdentifierCity_Identifier
	foreign key (IdentifierCity)
	references City.Identifier
	on delete no action
	on update no action

alter table [AddressContact]
add constraint FK_AddressContact_Address_IdentifierAddress_Identifier
	foreign key (IdentifierAddress)
	references [Address].Identifier
	on delete cascade
	on update cascade

alter table [AddressContact]
add constraint FK_AddressContact_Contact_IdentifierContact_Identifier
	foreign key (IdentifierContact)
	references [Contact].Identifier
	on delete cascade
	on update cascade

alter table [Contract]
add constraint FK_Contact_Civility_IdentifierCivility_Identifier
	foreign key (IdentifierCivility)
	references Civility.Identifier
	on delete no action
	on update no action
go

/*
Index

CLUSTER : Index qui determine l'ordre du stockage des lignes dans les pages de donn�es.
			Il ne peut exister qu'un seul index CLUSTER par table

NONCLUSTERED : Cr�� des fichiers d'indexation tri�s sur une ou plusieurs colonnes
				Les pages de l'index pointent sur les pages de donn�es.

Index implicites :
	-> Lors de la cr�ation d'une contrainte PRIMARY KEY (Cluster)
	-> Les de la cr�ation d'une contrainte unique (NONCLUSTERED)

	UNIQUE : Interdit les doublons
	CLUSTERED|NONCLUSTERED: Type d'index
	ASC | DESC : ordre du tri
	WHERE : restriction
	INCLUDE : Permet d'inclure des donn�es non index�es de la table � indexer
				Plus il y a de colonnes plus l'index est compliqu� � maintenir
	DROP_EXISTING : Permet de reg�n�er l'index s'il existait d�j�

	1000 indexs max par table (1 CLUSTERED + 999 NC) Il est d�conseill� d'avoir trop d'index
*/

create nonclustered index IX_City_ZipCode on City (ZipCode)
GO




