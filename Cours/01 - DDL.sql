--Script DDL : Data Definition Language

--s�lectionne une base de donn�es
USE [master]

--GO signifie que l'inerpr�teur de requ�tes SQL doit ex�cuter le lot d'instructions.
GO

--On check si la base existe d�j�
--IF EXISTS (<req�te>) permet de v�rifier si une requ�te retourne au moins un r�sultat
--sys.databases permet de lister les bases de donn�es de l'instance
IF EXISTS (SELECT TOP(1) 1 FROM sys.databases WHERE name = 'AddressBook')
BEGIN
	--On passe la base en mode mono-utilisateur (SINGLE_USER, une seule connexion possible)
	--L'option WITH ROLLBACK IMMEDIATE abandonne les transactions incompl�tes en cours 
	--et d�connecte les utilisateurs.
	ALTER DATABASE [AddressBook] SET
		SINGLE_USER WITH ROLLBACK IMMEDIATE

	DROP DATABASE [AddressBook]
END

GO
CREATE DATABASE [AddressBook]
ON PRIMARY --Fichier de donn�es
(
	--Nom logique du fichier
	NAME = AddressBook_dat 
	--Chemin du fichier de donn�es
	,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AddressBook.mdf'
	--Taille initiale du fichier
	,SIZE = 64MB
	--Taille maximum
	,MAXSIZE = 2GB
)
LOG ON --Fichier journal
(
	--Nom logique du fichier
	NAME = AddressBook_log 
	--Chemin du fichier de donn�es
	,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AddressBook.ldf'
	--Taille initiale du fichier
	,SIZE = 64MB
	--Taille maximum
	,MAXSIZE = UNLIMITED --2To pour le fichier de log et 16 To pour le fichier de donn�es
)

GO

GO
USE [AddressBook]

/*
-> Cha�nes ASCII (1 octet par caract�re)
	CHAR(n) :		Taille fixe, ajout du caract�re de bourage ' ' pour combler l'espace. n >= 1 && <= 8000
	VARCHAR(n) :	Taille variable, n>= 1 && <= 8000
	VARCHAR(MAX) :	Limit� � 2Go. A �viter pour des raisons de performance.

-> Cha�nes UNICODE (2 octets par caract�re donc n >= 1 && <= 4000)
	NCHAR(n)
	NVARCHAR(n)
	NVARCHAR(MAX)

-> Valeur num�riques exactes :
	TYNIINT :		Entier sur 1 octet
	SMALLINT :		Entier sur 2 octets
	INT :			Entier sur 4 octets
	BIGINT :		Entier sur 8 octets
	NUMERIC(p,s) :	Similaire � DECIMAL(p,s)
	DECIMAL(p,s) :	D�cimal � vigule fixe ( de 5 � 17 octets)
					p d�signe le nombre de chiffres total (entre 1 et 38, 18 par d�faut)
					s d�signe le nombre de d�cimales apr�s la virgule (entre 0 et p)
	SMALLMONEY :	D�cimal mon�taire sur 4 octets
	MONEY :			D�cimal mon�taire sur 8 octets

	<!> Utilisez DECIMAL au lieu de SMALLMONEY et MONEY

-> Valeur num�rique approximatives
	FLOAT :	Flotant de 4 � 8 octets
	REAL :	Flotant de 4 octets

	<!> provoques des erreurs d'arrondi dans les calculs (gestion sous forme de fraction).

-> Date et heure :
	DATE :				Date du 01/01/0001 au 31/12/9999 sur 3 octets
	DATETIME2(f) :		Date du 01/01/0001 au 31/12/9999 et heures (de 6 � 8 octets)
						f st le nombre de chiffres apr�s la seconde (de 0 � 7, 7 par d�faut)
	DATETIMEOFFSET :	Ajoute au DATETIME2(f) le fuseau horraire (10 octets)
	TIME(f) :			Heures sur 5 octets
						f st le nombre de chiffres apr�s la seconde (de 0 � 7, 7 par d�faut)

	<!> SMALLDATETIME et DATETIME non standardis� et commence au 01/01/1900

	<!> ROWVERSION anciennement TIMESTAMP n'a pas de signification temporelle pour SQL Server
		-> Utili� pour le v�rouillage optimiste

-> Cha�nes  binaires :
	BIT :				1 bit
	BINARY(n) :			donn�es binaires de longueur fixe; n >= 1 && <= 8000
	VARBINARY(n) :		donn�es binaires de longueur variable; n >= 1 && <= 8000
	VARBINARY(MAX) :	Limit� � 2 Go. A �viter pour des raisons de performance

-> Autre type de donn�es :
	HIERARCHYID :		Type syst�me de longueur variable (type CLR).
						Repr�sente une position dans une hi�rarchie.
	UNIQUEIDENTIFIER :	GUID sur 16 octets
	...

-> Types obsol�tes :
	TEXT, NTEXT et IMAGE

*/

GO
CREATE TABLE [AddressBook].[dbo].[City]
(
	--<COLUMN_NAME>	<TYPE>			[NULL|NOT NULL]	[IDENTITY]
	[Identifier]	BIGINT			NOT NULL		IDENTITY --IDENTITY => incr�ment automatique
	,[Name]			NVARCHAR(200)	NOT NULL
	,[ZipCode]		NVARCHAR(30)	NOT NULL
)

GO
CREATE TABLE [AddressBook].[dbo].[Civility]
(
	[Identifier]	BIGINT			NOT NULL	IDENTITY
	,[ShortName]	NVARCHAR(5)		NOT NULL	
	,[Name]			NVARCHAR(40)	NOT NULL	
)

GO
CREATE TABLE [AddressBook].[dbo].[Contact]
(
	[Identifier]			BIGINT			NOT NULL	IDENTITY
	,[IdentifierCivility]	BIGINT			NULL
	,[FirstName]			NVARCHAR(100)	NULL
	,[LastName]				NVARCHAR(100)	NOT NULL
	,[BirthDate]			DATE			NULL
	,[EMail]				NVARCHAR(100)	NULL
)

GO
CREATE TABLE [AddressBook].[dbo].[Address]
(
	[Identifier]			BIGINT			NOT NULL	IDENTITY
	,[IdentifierCity]		BIGINT			NOT NULL
	,[StreetNumber]			NVARCHAR(10)	NULL
	,[RoadType]				NVARCHAR(50)	NOT NULL
	,[RoadName]				NVARCHAR(300)	NULL
	,[Complement1]			NVARCHAR(200)	NULL
	,[Complement2]			NVARCHAR(200)	NULL
	,[Latitude]				DECIMAL(18,15)	NULL
	,[Longitude]			DECIMAL(18,15)	NULL
)

GO
CREATE TABLE [AddressBook].[dbo].[AddressContact]
(
	[Identifier]			BIGINT			NOT NULL	IDENTITY
	,[IdentifierAddress]	BIGINT			NOT NULL
	,[IdentifierContact]	BIGINT			NOT NULL
)

GO --Pour ajouter une colonne
ALTER TABLE [AddressBook].[dbo].[Address]
ADD
	[Code] NVARCHAR(30) NULL --Si il existe des enregistrement les nouveaux champs doivent �tre NULL

GO --Pour repasser la colonne en NOT NULL, les lignes doivent avoir une valeur
UPDATE
	[AddressBook].[dbo].[Address]
SET
	[Code] = N''
WHERE
	[Code] IS NULL

GO --On peut ensuite passer la colonne en NOT NULL
ALTER TABLE [AddressBook].[dbo].[Address]
ALTER COLUMN
	[Code] NVARCHAR(30) NOT NULL

GO --Pour supprimer une colonne
ALTER TABLE [AddressBook].[dbo].[Address]
DROP COLUMN
	[Code]

GO --Pour ajouter une colonne en NOT NULL dir�ctement
ALTER TABLE [AddressBook].[dbo].[Address]
ADD
	[Code] NVARCHAR(30) NOT NULL DEFAULT N''
	--Les valeurs existantent vont prendre pour valeur la valeur par d�faut.
	--Attention, la contrainte DEFAULT va avoir un nommage g�n�r� par ex :
		--DF__Address__Code__3A81B327
	--De plus, l'aplication d'une valeur par d�faut n'est pas forc�ment souhait�.
	--Par exemple une codificaiton obligatoire avec une valeur vide possible n'a pas de sens.

ALTER TABLE [AddressBook].[dbo].[City]
ADD
	[IsActive] BIT NOT NULL DEFAULT 1

GO
DECLARE @sqlQuery NVARCHAR(MAX); --D�claration d'une variable

/*
--Construction d'une cha�ne pour supprimer les contraintes DEFAULT existantes
--STRING_AGG est une fonction de concat�nation de cha�ne pour obtenir en une ligne le r�sultat de plusieurs lignes.
SELECT 
	@sqlQuery = STRING_AGG(N'ALTER TABLE [' + OBJECT_NAME(parent_object_id) 
							+ N'] DROP CONSTRAINT [' + name + N']', NCHAR(13)) --NCHAR(13) est le carac�re de s�paration des lignes
FROM 
	sys.default_constraints		--sys.default_constraints liste des contraintes DEFAULT existantes dans la base en cours.

----|-name--|													
--1 | 'TOTO'  |
--2 | 'TATA'  |
--STRING_AGG => 
----|-name--|													
--1 | 'TOTO\nTATA'  |

PRINT @sqlQuery					--PRINT affiche une variable dans la console
EXEC sp_executesql @sqlQuery	--Ex�cute du code SQL de mani�re dynamique.
*/

/*
Les contraintes ont pour but de programmer les r�gles de gestion au niveau des colonnes.
On peut les d�clarer en m�me temps que la table (inline constraints).
Il est pr�f�rable de les d�clarer s�par�ment pur ne pas avoir � respecter un ordre de cr�ation des tables.

Chaque contrainte eut s'apliquer � un plusieurs colonnes (coupl, triplets...)

	UNIQUE (UK) :		Impose une valeur distrinct pour chaque enregistrement. Les valeurs NULL sont autoris�es.
	PRIMARY KEY (PK) :	Cl� primaire de la table . Les valeurs ne peuvent �tre ni NULL ni identiques.
						Un index CLUSTURED est g�n�r� auomatiquement.
	FOREIGN KEY (FK) :	Cl� �trang�re, permet de maintenir l'int�grit� r�f�rentielle.
						Attention, aucun index n'est g�n�r� automatiquement.
	DEFAULT (DK) :		Valeur par d�faut.
	CHECK (CK) :		Impose un domaine de valeurs ou un condition entre colonnes
*/

--PK
GO
ALTER TABLE [AddressBook].[dbo].[City]
ADD CONSTRAINT [PK_City_Identifier]
	PRIMARY KEY ([Identifier])

GO
ALTER TABLE [AddressBook].[dbo].[Civility]
ADD CONSTRAINT [PK_Civility_Identifier]
	PRIMARY KEY ([Identifier])
	
GO
ALTER TABLE [AddressBook].[dbo].[Contact]
ADD CONSTRAINT [PK_Contact_Identifier]
	PRIMARY KEY ([Identifier])

GO
ALTER TABLE [AddressBook].[dbo].[Address]
ADD CONSTRAINT [PK_Address_Identifier]
	PRIMARY KEY ([Identifier])
	
GO
ALTER TABLE [AddressBook].[dbo].[AddressContact]
ADD CONSTRAINT [PK_AddressContact_Identifier]
	PRIMARY KEY ([Identifier])

--UK

--Il est impossible d'asocier 2 fis un contact � une adrese.
ALTER TABLE [AddressBook].[dbo].[AddressContact]
ADD CONSTRAINT [UK_AddressContact_IdentifierAddress_IdentifierContact]
	UNIQUE ([IdentifierAddress], [IdentifierContact])

--FK

/*
Int�grit� r�f�rentielle

Actions � mener sur UPDATE | DELETE sur la/les colonne(s) r�f�renc�e(s)
CASCADE :		R�percute ur les enregistrements li�s.
SET NULL :		Donne pour valeur NULL aux lignes de la clef �trang�re qui pointent sur l'enregistrement affect�.
				Possible seulement si la/les colonne(s) FK accepte(ent) le marqueur NULL.
SET DEFAULT :	Applique la valeur par d�faut aux lignes de la clef �trang�re qui pointent sur l'enregistrement affect�.
				Possible seulement si la/les colonne(s) FK ont une contrainte DEFAULT.
NO ACTION :		D�clenche une erreur si l'enregistrement est r�f�renc� par la clef �trang�re. (comportement par d�faut)

*/

GO ---> Address -> City (NO ACTION)
ALTER TABLE [AddressBook].[dbo].[Address]
ADD CONSTRAINT [FK_Address_City_IdentifierCity_Identifier]
	FOREIGN KEY ([IdentifierCity])
	REFERENCES [AddressBook].[dbo].[City] ([Identifier])
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

GO ---> AddressContact -> Address (CASCADE)
ALTER TABLE [AddressBook].[dbo].[AddressContact]
ADD CONSTRAINT [FK_AddressContact_Address_IdentifierAddress_Identifier]
	FOREIGN KEY ([IdentifierAddress])
	REFERENCES [AddressBook].[dbo].[Address] ([Identifier])
	ON DELETE CASCADE
	ON UPDATE CASCADE

GO ---> AddressContact -> Contact (CASCADE)
ALTER TABLE [AddressBook].[dbo].[AddressContact]
ADD CONSTRAINT [FK_AddressContact_Contact_IdentifierContact_Identifier]
	FOREIGN KEY ([IdentifierContact])
	REFERENCES [AddressBook].[dbo].[Contact] ([Identifier])
	ON DELETE CASCADE
	ON UPDATE CASCADE
GO ---> Contact -> Civility (NO ACTION)
ALTER TABLE [AddressBook].[dbo].[Contact]
ADD CONSTRAINT [FK_Contact_Civility_IdentifierCivility_Identifier]
	FOREIGN KEY ([IdentifierCivility])
	REFERENCES [AddressBook].[dbo].[Civility] ([Identifier])
	ON DELETE NO ACTION
	ON UPDATE NO ACTION


/*
Index (IX)

CLUSTER :		Index qui d�termine l'ordre du stockage des lignes dans les pages de donn�es.
				Il ne peut exister qu'un seul index CLUSTER par table.

NONCLUSTURED :	Cr�er des fichiers d'indexation tri� sur une ou plusieurs colonnes.
				Les pages e l'index pointent sur les pages de donn�es.

Index implicite :
	-> Lors de la cr�ation d'une contrainte PRIMARY KEY (index CLUSTER)
	-> Lors de la cr�ation d'une contrainte UNIQUE (index NONCLUSTERED)

	UNIQUE :					Interdit les doublons
	CLUSTERED|NONCLUSTERED :	D�termine le type d'index
	ASC | DESC :				D�termine l'ordre du tri de l'index (ASC par d�faut)
	WHERE :						Applique une restriction sur les lignes � indexer
	INCLUDE :					Permet d'inclure des donn�es non inex�es de la table � indexer.
								Permet d'�viter une double lecture (index + page de donn�es).
								Plus le nombre de colonne �lev�, plus l'index est compliqu� � maintenir.
	DROP_EXISTING :				Permet de reg�n�rer l'index s'il existait d�j� (par d�faut OFF).

	1000 index maximum par table (1 CLUSTURED + 999 NONCLUSTURED)
	Il est d�conseill� d'avoir trop d'indexes.
*/

GO
CREATE NONCLUSTERED INDEX  IX_City_ZipCode ON [AddressBook].[dbo].[City]
(
	[ZipCode]
)

GO
CREATE NONCLUSTERED INDEX  IX_City_Name ON [AddressBook].[dbo].[City]
(
	[Name]
)
INCLUDE
(
	[ZipCode]
)

