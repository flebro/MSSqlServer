--Script DDL : Data Definition Language

--sélectionne une base de données
USE [master]

--GO signifie que l'inerpréteur de requêtes SQL doit exécuter le lot d'instructions.
GO

--On check si la base existe déjà
--IF EXISTS (<reqête>) permet de vérifier si une requête retourne au moins un résultat
--sys.databases permet de lister les bases de données de l'instance
IF EXISTS (SELECT TOP(1) 1 FROM sys.databases WHERE name = 'AddressBook')
BEGIN
	--On passe la base en mode mono-utilisateur (SINGLE_USER, une seule connexion possible)
	--L'option WITH ROLLBACK IMMEDIATE abandonne les transactions incomplètes en cours 
	--et déconnecte les utilisateurs.
	ALTER DATABASE [AddressBook] SET
		SINGLE_USER WITH ROLLBACK IMMEDIATE

	DROP DATABASE [AddressBook]
END

GO
CREATE DATABASE [AddressBook]
ON PRIMARY --Fichier de données
(
	--Nom logique du fichier
	NAME = AddressBook_dat 
	--Chemin du fichier de données
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
	--Chemin du fichier de données
	,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AddressBook.ldf'
	--Taille initiale du fichier
	,SIZE = 64MB
	--Taille maximum
	,MAXSIZE = UNLIMITED --2To pour le fichier de log et 16 To pour le fichier de données
)

GO

GO
USE [AddressBook]

/*
-> Chaînes ASCII (1 octet par caractère)
	CHAR(n) :		Taille fixe, ajout du caractère de bourage ' ' pour combler l'espace. n >= 1 && <= 8000
	VARCHAR(n) :	Taille variable, n>= 1 && <= 8000
	VARCHAR(MAX) :	Limité à 2Go. A éviter pour des raisons de performance.

-> Chaînes UNICODE (2 octets par caractère donc n >= 1 && <= 4000)
	NCHAR(n)
	NVARCHAR(n)
	NVARCHAR(MAX)

-> Valeur numériques exactes :
	TYNIINT :		Entier sur 1 octet
	SMALLINT :		Entier sur 2 octets
	INT :			Entier sur 4 octets
	BIGINT :		Entier sur 8 octets
	NUMERIC(p,s) :	Similaire à DECIMAL(p,s)
	DECIMAL(p,s) :	Décimal à vigule fixe ( de 5 à 17 octets)
					p désigne le nombre de chiffres total (entre 1 et 38, 18 par défaut)
					s désigne le nombre de décimales après la virgule (entre 0 et p)
	SMALLMONEY :	Décimal monétaire sur 4 octets
	MONEY :			Décimal monétaire sur 8 octets

	<!> Utilisez DECIMAL au lieu de SMALLMONEY et MONEY

-> Valeur numérique approximatives
	FLOAT :	Flotant de 4 à 8 octets
	REAL :	Flotant de 4 octets

	<!> provoques des erreurs d'arrondi dans les calculs (gestion sous forme de fraction).

-> Date et heure :
	DATE :				Date du 01/01/0001 au 31/12/9999 sur 3 octets
	DATETIME2(f) :		Date du 01/01/0001 au 31/12/9999 et heures (de 6 à 8 octets)
						f st le nombre de chiffres après la seconde (de 0 à 7, 7 par défaut)
	DATETIMEOFFSET :	Ajoute au DATETIME2(f) le fuseau horraire (10 octets)
	TIME(f) :			Heures sur 5 octets
						f st le nombre de chiffres après la seconde (de 0 à 7, 7 par défaut)

	<!> SMALLDATETIME et DATETIME non standardisé et commence au 01/01/1900

	<!> ROWVERSION anciennement TIMESTAMP n'a pas de signification temporelle pour SQL Server
		-> Utilié pour le vérouillage optimiste

-> Chaînes  binaires :
	BIT :				1 bit
	BINARY(n) :			données binaires de longueur fixe; n >= 1 && <= 8000
	VARBINARY(n) :		données binaires de longueur variable; n >= 1 && <= 8000
	VARBINARY(MAX) :	Limité à 2 Go. A éviter pour des raisons de performance

-> Autre type de données :
	HIERARCHYID :		Type système de longueur variable (type CLR).
						Représente une position dans une hiérarchie.
	UNIQUEIDENTIFIER :	GUID sur 16 octets
	...

-> Types obsolètes :
	TEXT, NTEXT et IMAGE

*/

GO
CREATE TABLE [AddressBook].[dbo].[City]
(
	--<COLUMN_NAME>	<TYPE>			[NULL|NOT NULL]	[IDENTITY]
	[Identifier]	BIGINT			NOT NULL		IDENTITY --IDENTITY => incrément automatique
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
	[Code] NVARCHAR(30) NULL --Si il existe des enregistrement les nouveaux champs doivent être NULL

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

GO --Pour ajouter une colonne en NOT NULL dirèctement
ALTER TABLE [AddressBook].[dbo].[Address]
ADD
	[Code] NVARCHAR(30) NOT NULL DEFAULT N''
	--Les valeurs existantent vont prendre pour valeur la valeur par défaut.
	--Attention, la contrainte DEFAULT va avoir un nommage généré par ex :
		--DF__Address__Code__3A81B327
	--De plus, l'aplication d'une valeur par défaut n'est pas forcément souhaité.
	--Par exemple une codificaiton obligatoire avec une valeur vide possible n'a pas de sens.

ALTER TABLE [AddressBook].[dbo].[City]
ADD
	[IsActive] BIT NOT NULL DEFAULT 1

GO
DECLARE @sqlQuery NVARCHAR(MAX); --Déclaration d'une variable

/*
--Construction d'une chaîne pour supprimer les contraintes DEFAULT existantes
--STRING_AGG est une fonction de concaténation de chaîne pour obtenir en une ligne le résultat de plusieurs lignes.
SELECT 
	@sqlQuery = STRING_AGG(N'ALTER TABLE [' + OBJECT_NAME(parent_object_id) 
							+ N'] DROP CONSTRAINT [' + name + N']', NCHAR(13)) --NCHAR(13) est le caracère de séparation des lignes
FROM 
	sys.default_constraints		--sys.default_constraints liste des contraintes DEFAULT existantes dans la base en cours.

----|-name--|													
--1 | 'TOTO'  |
--2 | 'TATA'  |
--STRING_AGG => 
----|-name--|													
--1 | 'TOTO\nTATA'  |

PRINT @sqlQuery					--PRINT affiche une variable dans la console
EXEC sp_executesql @sqlQuery	--Exécute du code SQL de manière dynamique.
*/

/*
Les contraintes ont pour but de programmer les règles de gestion au niveau des colonnes.
On peut les déclarer en même temps que la table (inline constraints).
Il est préférable de les déclarer séparément pur ne pas avoir à respecter un ordre de création des tables.

Chaque contrainte eut s'apliquer à un plusieurs colonnes (coupl, triplets...)

	UNIQUE (UK) :		Impose une valeur distrinct pour chaque enregistrement. Les valeurs NULL sont autorisées.
	PRIMARY KEY (PK) :	Clé primaire de la table . Les valeurs ne peuvent être ni NULL ni identiques.
						Un index CLUSTURED est généré auomatiquement.
	FOREIGN KEY (FK) :	Clé étrangère, permet de maintenir l'intégrité référentielle.
						Attention, aucun index n'est généré automatiquement.
	DEFAULT (DK) :		Valeur par défaut.
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

--Il est impossible d'asocier 2 fis un contact à une adrese.
ALTER TABLE [AddressBook].[dbo].[AddressContact]
ADD CONSTRAINT [UK_AddressContact_IdentifierAddress_IdentifierContact]
	UNIQUE ([IdentifierAddress], [IdentifierContact])

--FK

/*
Intégrité référentielle

Actions à mener sur UPDATE | DELETE sur la/les colonne(s) référencée(s)
CASCADE :		Répercute ur les enregistrements liés.
SET NULL :		Donne pour valeur NULL aux lignes de la clef étrangère qui pointent sur l'enregistrement affecté.
				Possible seulement si la/les colonne(s) FK accepte(ent) le marqueur NULL.
SET DEFAULT :	Applique la valeur par défaut aux lignes de la clef étrangère qui pointent sur l'enregistrement affecté.
				Possible seulement si la/les colonne(s) FK ont une contrainte DEFAULT.
NO ACTION :		Déclenche une erreur si l'enregistrement est référencé par la clef étrangère. (comportement par défaut)

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

CLUSTER :		Index qui détermine l'ordre du stockage des lignes dans les pages de données.
				Il ne peut exister qu'un seul index CLUSTER par table.

NONCLUSTURED :	Créer des fichiers d'indexation trié sur une ou plusieurs colonnes.
				Les pages e l'index pointent sur les pages de données.

Index implicite :
	-> Lors de la création d'une contrainte PRIMARY KEY (index CLUSTER)
	-> Lors de la création d'une contrainte UNIQUE (index NONCLUSTERED)

	UNIQUE :					Interdit les doublons
	CLUSTERED|NONCLUSTERED :	Détermine le type d'index
	ASC | DESC :				Détermine l'ordre du tri de l'index (ASC par défaut)
	WHERE :						Applique une restriction sur les lignes à indexer
	INCLUDE :					Permet d'inclure des données non inexées de la table à indexer.
								Permet d'éviter une double lecture (index + page de données).
								Plus le nombre de colonne élevé, plus l'index est compliqué à maintenir.
	DROP_EXISTING :				Permet de regénérer l'index s'il existait déjà (par défaut OFF).

	1000 index maximum par table (1 CLUSTURED + 999 NONCLUSTURED)
	Il est déconseillé d'avoir trop d'indexes.
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

