DELETE FROM AddressContact
DELETE FROM Address
DELETE FROM Contact
DELETE FROM Civility
DELETE FROM City

/***
	DML : Data Manipulation Language
***/

--INSERT

GO
--Désactive l'auto incrément pour les colonnes IDENTITY d'une table
--Une seule table par session peut avoir la propriété IDENTITY_INSERT à ON
SET IDENTITY_INSERT [AddressBook].[dbo].[City] ON

INSERT INTO [AddressBook].[dbo].[City]
(
	Identifier
	,Name
	,Zipcode
	,IsActive
)
VALUES
	(	1,	N'PARIS',		N'75001',	1)
	,(	2,	N'PARIS',		N'75002',	1)
	,(	3,	N'PARIS',		N'75003',	1)
	,(	4,	N'PARIS',		N'75004',	1)
	,(	5,	N'PARIS',		N'75005',	1)
	,(	6,	N'PARIS',		N'75006',	1)
	,(	7,	N'PARIS',		N'75007',	1)
	,(	8,	N'PARIS',		N'75008',	1)
	,(	9,	N'PARIS',		N'75009',	1)
	,(	10,	N'PARIS',		N'75010',	1)
	,(	11,	N'LAVAL',		N'53000',	1)
	,(	12,	N'ANGERS',		N'49000',	1)
	,(	13,	N'ANGERS',		N'49100',	1)
	,(	14,	N'SEGRÉ',		N'49500',	1)
	,(	15,	N'NYOISEAU',	N'49500',	1);
--Pour réactiver l'auto incrément
SET IDENTITY_INSERT [AddressBook].[dbo].[City] OFF

GO
SET IDENTITY_INSERT [AddressBook].[dbo].[Civility] ON

INSERT INTO [AddressBook].[dbo].[Civility]
(
	[Identifier]
	,[ShortName]
	,[Name]
)
VALUES
	(1,		N'M.',		N'Monsieur')
	,(2,	N'Mme.',	N'Madame')
	,(3,	N'Autre',	N'Autre');

SET IDENTITY_INSERT [AddressBook].[dbo].[Civility] OFF

GO
SET IDENTITY_INSERT [AddressBook].[dbo].[Contact] ON

INSERT INTO [AddressBook].[dbo].[Contact]
(
	[Identifier]
	,[FirstName]
	,[LastName]
	,[BirthDate]
	,[EMail]
	,[IdentifierCivility]
)
VALUES
	(1,		N'Benjamin',	N'DAGUÉ',	'24/12/1987',	N'benjamin.dague@etskirsch.fr',		1)
	,(2,	N'Guillaume',	N'KIRSCH',	'01/03/1980',	N'guillaume.kirsch@etskirsch.fr',	1)
	,(3,	N'Jean',		N'DUPONT',	'05/06/1990',	NULL,								1)
	,(4,	N'Lucie',		N'DURAND',	'30/08/2000',	NULL,								2)
	,(5,	N'Grégory',		N'DURAND',	'07/07/1999',	NULL,								1)
	,(6,	N'Antoine',		N'TOTO',	'04/06/1985',	NULL,								1)
	,(7,	NULL,			N'TOTO',	'04/06/1995',	NULL,								NULL)
	,(8,	N'Camille',		N'TOTO',	'07/11/1997',	NULL,								2)
	,(9,	N'Paul',		N'DUPOND',	'24/03/1993',	NULL,								1)
	,(10,	N'Marion',		N'TUTU',	'24/03/1993',	NULL,								2)
	,(11,	N'Marc',		N'DUPOND',	'10/10/1985',	NULL,								1)
	,(12,	N'Marie',		N'DUPOND',	'10/10/1985',	NULL,								2)
	,(13,	N'Patrice',		N'LOULOU',	NULL,			NULL,								1)
	,(14,	N'Ludivine',	N'LOULOU',	NULL,			NULL,								2);

SET IDENTITY_INSERT [AddressBook].[dbo].[Contact] OFF

GO
SET IDENTITY_INSERT [AddressBook].[dbo].[Address] ON
INSERT INTO [AddressBook].[dbo].[Address]
(
	[Identifier]
	,[Code]
	,[StreetNumber]
	,[RoadType]
	,[RoadName]
	,[IdentifierCity]
)
VALUES
	(1,		N'',	N'20',		N'RUE',			N'D''ARGENTREUIL',			1)
	,(2,	N'',	N'15',		N'RUE',			N'BACHAUMONT',				2)
	,(3,	N'',	N'2BIS',	N'RUE',			N'VIVIENNE',				2)
	,(4,	N'',	N'113',		N'BOULEVARD',	N'JEAN MOULIN',				12)
	,(5,	N'',	N'114',		N'BOULEVARD',	N'JEAN MOULIN',				12)
	,(6,	N'',	N'2',		N'AVENUE',		N'DES ACACIAS',				14)
	,(7,	N'',	N'7',		N'AVENUE',		N'DES ACACIAS',				14)
	,(8,	N'',	N'9',		N'AVENUE',		N'DU GÉNÉRAL D''ANDIGNÉ',	14)
	,(9,	N'',	N'52',		N'RUE',			N'GENEVIÈVE VERGER',		15)
	,(10,	N'',	N'30',		N'RUE',			N'GENEVIÈVE VERGER',		15)
	,(11,	N'',	N'10',		N'RUE',			N'DE PARIS',				11)
	,(12,	N'',	N'1',		N'AVENUE',		N'DE L''OPÉRA',				1)
	,(13,	N'',	N'2',		N'AVENUE',		N'DE L''OPÉRA',				1)
	,(14,	N'',	N'3',		N'AVENUE',		N'DE L''OPÉRA',				1);

SET IDENTITY_INSERT [AddressBook].[dbo].[Address] OFF

INSERT INTO [AddressBook].[dbo].[AddressContact]
(
	[IdentifierAddress]
	,[IdentifierContact]
)
VALUES
	(1,		1)
	,(1,	2)	
	,(3,	3)
	,(3,	4)
	,(3,	5)
	,(4,	6)
	,(5,	7)
	,(6,	8)
	,(9,	9)
	,(10,	10)
	,(11,	11);

/*

Pour récupérer la dernière valeur IDENTITY générée :

IDENT_CURRENT :		Pour un table spécifiée, dans toutes les sessions et pour tous les scopes.
@@IDENTITY :		Pour toutes les tables, dans la session en cours et dans tous les scopes.
SCOPE_IDENTITY :	Pour toutes les tables, dans la session en cours dans le scope en cours.

*/

--SELECT
--	@@IDENTITY
--	,SCOPE_IDENTITY()
--	,IDENT_CURRENT('[AddressBook].[dbo].[AddressContact]')

UPDATE
	[AddressBook].[dbo].[City]
SET
	[Name] = LOWER(Name)

UPDATE
	[AddressBook].[dbo].[City]
SET
	[Name] = UPPER(Name)
WHERE
	[Name] = 'PARIS'


--Collate permet de modifier le classement utilisé pour la requête.
--C'est pratique par exemple pour comparrer des chaînes avec des accents.
SELECT 
	IIF('é' = 'e' COLLATE Latin1_General_CI_AI, 1, 0) 
	,IIF('é' = 'e', 1, 0) 

--Sur une oppération de concaténation/calcul avec '+', une valeur NULL va rendre le résultat NULL
--La fonction CONCAT va gérer ce cas pour les chaînes.
--Autrement, il est possible d'utiliser la fonction ISNULL
SELECT 
	CONCAT('test','chaine2', NULL)
	,'test' + 'chaine2' + ''
	,'test' + 'chaine2' + ISNULL(NULL, '')

SELECT 
	t0.Identifier
	,CONCAT(t0.LastName, ' ' + t0.FirstName)	AS FullName
	,t0.BirthDate
	,(CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)) - CONVERT(CHAR(8),t0.BirthDate, 112)) /10000	AS Age
FROM
	Contact AS t0

ALTER TABLE [AddressBook].[dbo].[Contact]
ADD
	Age AS ((CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)) - CONVERT(CHAR(8),BirthDate, 112)) /10000)
	,FullName AS (CONCAT(LastName, ' ' + FirstName)) PERSISTED

SELECT * FROM Contact