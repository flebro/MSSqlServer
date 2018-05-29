USE [AddressBook]
GO

SELECT
	t0.Identifier
	,t0.Name		AS [Nom ville]
	,t0.ZipCode		AS [Code postal]
FROM
	City AS t0

--Limiter le nombre d'enregistrement : TOP(n)
SELECT TOP(1)
	t0.Identifier
	,t0.Name		AS [Nom ville]
	,t0.ZipCode		AS [Code postal]
FROM
	City AS t0

--Supprimer les doublons : DISTINCT
SELECT DISTINCT
	t0.Name		AS [Nom ville]
FROM
	City AS t0

--Ordonner les r�sultats : ORDER BY
SELECT DISTINCT
	t0.Name		AS [Nom ville]
FROM
	City AS t0
ORDER BY
	t0.Name ASC --ASC (par d�faut) | DESC
--Avec ORDER BY, il est possible d'utiliser les alias de la projection.
--Ceci est li� � l'ordre d'ex�cution des mots clefs :
-- FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY


/**** WHERE ***/
SELECT
	*
FROM
	City AS t0
WHERE
	t0.Identifier = 11 -- (<> | !=) | < | > | <= | >=

--Op�rateur BETWEEN
SELECT
	*
FROM
	City AS t0
WHERE
	t0.Identifier BETWEEN 7 AND 11
	--t0.Identifier NOT BETWEEN 7 AND 11 --NOT est l'op�rateur d'inversion

--Op�rateur LIKE
--Commence par LAV
SELECT * FROM City AS t0 WHERE t0.Name LIKE 'LAV%'

--Termine par LAV
SELECT * FROM City AS t0 WHERE t0.Name LIKE '%LAV'

--Contient AVA
SELECT * FROM City AS t0 WHERE t0.Name LIKE '%AVA%'

--Contient deux A
SELECT * FROM City AS t0 WHERE t0.Name LIKE '%A%A%'

--Termine par A suivi d'un caract�re
SELECT * FROM City AS t0 WHERE t0.Name LIKE '%A_'

--Commence par un caract�re entre a et l
SELECT * FROM City AS t0 WHERE t0.Name LIKE '[a-l]%'

--Ne commence pas par un caract�re entre a et l
SELECT * FROM City AS t0 WHERE t0.Name LIKE '[^a-l]%'

--Attention LIKE '%...' sont des requ�tes qui n'utilisent pas les indexes

--Conversion de donn�es :
--	> CAST respecte la norme SQL ANSI et est plus rapide
--	> CONVERT permet de faire du formatage de donn�e en m�me temps que la conversion

SELECT
	CAST(t0.ZipCode AS BIGINT) + 10000 AS ZipCode_BIGINT_CAST
	,CONVERT(BIGINT, t0.ZipCode) + 10000 AS ZipCode_BIGINT_CAST
FROM
	City AS t0
WHERE
	ISNUMERIC(t0.ZipCode) = 1 --On garde uniquement les cha�nes qui contiennent une donn�e num�rique.

--Regroupement : GROUP BY
--Nombre de code postal par nom de ville
SELECT
	t0.Name
	,COUNT(1) AS NbCodePostal
FROM
	City AS t0
GROUP BY
	t0.Name


--Nombre d'adresse par ville et par type de rue
SELECT
	t1.Name
	,t0.RoadType
	,COUNT(1) AS NbAdresse
FROM
	Address AS t0
INNER JOIN
	City AS t1 ON t0.IdentifierCity = t1.Identifier
GROUP BY
	t1.Name
	,t0.RoadType

--Nombre d'adresse par rue (nom rue + type de rue + ville) pour les rues qui ont au moins 2 adresses
SELECT
	t1.Name
	,t0.RoadType
	,t0.RoadName
	,COUNT(1) AS NbAdresse
FROM
	Address AS t0
INNER JOIN
	City AS t1 ON t0.IdentifierCity = t1.Identifier
GROUP BY
	t1.Name
	,t0.RoadType
	,t0.RoadName
HAVING
	COUNT(1) > 1 --HAVING permet d'appliquer des conditions sur le r�sultat d'une agr�gation

--On peut obtenir le m�me r�sultat sans le having avec une sous requ�te.
SELECT
	*
FROM
(
	SELECT
		t1.Name
		,t0.RoadType
		,t0.RoadName
		,COUNT(1) AS NbAdresse
	FROM
		Address AS t0
	INNER JOIN
		City AS t1 ON t0.IdentifierCity = t1.Identifier
	GROUP BY
		t1.Name
		,t0.RoadType
		,t0.RoadName
) AS t0
WHERE
	t0.NbAdresse > 1

--En une requ�te (V1 : sous-req�te possible puis essayer V2 : un seul SELECT)
	--Total adresse regroup� par IdentifierCity et par RoadType
	--Total adresse regroup� par IdentifierCity
	--Total adresse g�n�ral

--V1 : UNION

SELECT
	t0.IdentifierCity
	,t0.RoadType
	,COUNT(*)			AS Total
FROM
	Address AS t0
GROUP BY
	t0.IdentifierCity
	,t0.RoadType
UNION ALL
SELECT
	t0.IdentifierCity
	,NULL				AS RoadType
	,COUNT(*)			AS Total
FROM
	Address AS t0
GROUP BY
	t0.IdentifierCity
UNION ALL
SELECT
	NULL				AS IdentifierCity
	,NULL				AS RoadType
	,COUNT(*)			AS Total
FROM
	Address AS t0


--V1 : sous-requ�te
SELECT DISTINCT
	t0.IdentifierCity
	,t0.RoadType
	,t1.Total			AS TotalVilleTypeRue
	,t2.Total			AS TotalVille
	,t3.Total
FROM
	Address AS t0
INNER JOIN
(
	SELECT
		t0.IdentifierCity
		,t0.RoadType
		,COUNT(*)			AS Total
	FROM
		Address AS t0
	GROUP BY
		t0.IdentifierCity
		,t0.RoadType
) AS t1 ON t0.IdentifierCity = t1.IdentifierCity AND t0.RoadType = t1.RoadType
INNER JOIN
(
	SELECT
		t0.IdentifierCity
		,COUNT(*)			AS Total
	FROM
		Address AS t0
	GROUP BY
		t0.IdentifierCity
) AS t2 ON t0.IdentifierCity = t2.IdentifierCity
CROSS JOIN
(
	SELECT
		COUNT(*)			AS Total
	FROM
		Address AS t0
) AS t3



--V2 : OVER

SELECT
	t0.Identifier
	,t0.IdentifierCity
	,t0.RoadType
	,COUNT(*) OVER (PARTITION BY t0.IdentifierCity, t0.RoadType)	AS TotalVilleRoadType
	,COUNT(*) OVER (PARTITION BY t0.IdentifierCity)					AS TotalVille
	,COUNT(*) OVER ()												AS Total
FROM
	Address AS t0

--V2 : ROLL UP
SELECT
	t0.IdentifierCity
	,t0.RoadType
	,COUNT(t0.Identifier) AS Total
	,GROUPING(t0.IdentifierCity) AS GroupingByIdentifierCity
	,GROUPING(t0.RoadType) AS GroupingByRoadType
FROM
	Address AS t0
GROUP BY ROLLUP
(
	t0.IdentifierCity
	,t0.RoadType
)
--GROUP BY IdentifierCity + RoadType
--GROUP BY IdentifierCity
--GROUP BY

--V3 : CUBE
SELECT
	t0.IdentifierCity
	,t0.RoadType
	,t0.RoadName
	,COUNT(t0.Identifier) AS Total
FROM
	Address AS t0
GROUP BY CUBE
(
	t0.IdentifierCity
	,t0.RoadType
	,t0.RoadName
)

--GROUP BY IdentifierCity + RoadType
--GROUP BY IdentifierCity
--GROUP BY RoadType
--GROUP BY

--GROUPING SETS permet de composer � la demande les combinaisons d'agr�gats
SELECT
	t0.IdentifierCity
	,t0.RoadType
	,t0.RoadName
	,COUNT(t0.Identifier) AS Total
FROM
	Address AS t0
GROUP BY GROUPING SETS
(
	t0.IdentifierCity
	,t0.RoadType
	,(t0.IdentifierCity, t0.RoadName)
	,()
)


/***Op�rateurs ensemblistes***/

--INTERSECT : garde les �l�ments pr�sents dans les deux ensembles
SELECT * FROM Contact AS t0 WHERE t0.FirstName LIKE 'B%'
INTERSECT
SELECT * FROM Contact AS t0 WHERE t0.LastName LIKE 'D%'

--UNION : union des deux ensembles et suppression des doublons
SELECT 'test'
UNION
SELECT 'toto'
UNION
SELECT 'test'

--UNION ALL : union des deux ensembles qui garde les doublons
SELECT 'test'
UNION ALL
SELECT 'toto'
UNION ALL
SELECT 'test'

--EXCEPT : Supprime les �l�ments de l'ensemble A qui sont dans l'ensmble B
SELECT * FROM Contact AS t0 WHERE t0.LastName LIKE 'D%'
EXCEPT
SELECT * FROM Contact AS t0 WHERE t0.FirstName LIKE 'B%'

--CROSS JOIN : Produit cart�sien entre deux ensembles
SELECT
	*
FROM
	Address AS t0
CROSS JOIN
	City AS t1

--Ancienne norme SQL :
SELECT * FROM Address AS t0, City AS t1

--Jointures

--Equijointure

SELECT 
	* 
FROM 
	Address AS t0
INNER JOIN
	City AS t1 ON t0.IdentifierCity = t1.Identifier
	

--Ancienne norme SQL :
SELECT * FROM Address AS t0, City AS t1 WHERE t0.IdentifierCity = t1.Identifier
/*
Exercice :	Pour chaque adresse, afficher le nom et le code postal de la vile, le nom de la rue
			Le nom et le pr�nom des habitants. On ne conserve que les logements occup�s.
*/

SELECT
	t3.Name
	,t3.ZipCode
	,t2.RoadName
	,t1.FullName
FROM
	AddressContact AS t0
INNER JOIN
	Contact AS t1 ON t0.IdentifierContact = t1.Identifier
INNER JOIN
	Address AS t2 ON t0.IdentifierAddress = t2.Identifier
INNER JOIN
	City AS t3 ON t2.IdentifierCity = t3.Identifier

--Jointures externes
--LEFT JOIN et RIGHT JOIN

--On r�cup�re tous les enregistrements de A avec les enregistrements de B si il y a une association.
--On ne r�cup�re pas les enregistrements de B si il ne sont pas associ�s � au moins un enregistrement de A.
--SELECT * FROM A LEFT JOIN B ON A.IdentifierB = B.Identifier

--On r�cup�re tous les enregistrements de B avec les enregistrements de A si il y a une association.
--On ne r�cup�re pas les enregistrements de A si il ne sont pas associ�s � au moins un enregistrement de B.
--SELECT * FROM A RIGHT JOIN B ON A.IdentifierB = B.Identifier

--S�lectionner les villes avec les adresses + les villes sans adresse (on prend tous les champs)
SELECT
	*
FROM
	City AS t0
LEFT JOIN
	Address AS t1 ON t0.Identifier = t1.IdentifierCity

SELECT
	*
FROM
	Address AS t0
RIGHT JOIN
	City AS t1 ON t1.Identifier = t0.IdentifierCity

--Uniquement les villes sans adresse :
SELECT
	*
FROM
	City AS t0
LEFT JOIN
	Address AS t1 ON t0.Identifier = t1.IdentifierCity
WHERE
	t1.Identifier IS NULL

--Pour la projection des exo 1 � 4 : Contact.FullName et Civility.ShortName
--EXO1 : Pour chaque personne afficher la civilit� associ�e, garder �galement les personnes sans civilit�.
--EXO2 : Afficher les personnes sans civilit�.
--EXO3 : Pour chaque civilit� afficher les personnes associ�es, garder les civilit�s sans personne.
--EXO4 : Afficher les civilit�s sans personne.
--EXO5 : Pour chaque ville, afficher le nombre d'adresses associ�es. Les villes sans adresse doivent appara�tres.


--EXO1 : Pour chaque personne afficher la civilit� associ�e, garder �galement les personnes sans civilit�.
SELECT
	*
FROM
	Contact AS t0
LEFT JOIN
	Civility AS t1 ON t0.IdentifierCivility = t1.Identifier

--EXO2 : Afficher les personnes sans civilit�.
SELECT
	*
FROM
	Contact AS t0
LEFT JOIN
	Civility AS t1 ON t0.IdentifierCivility = t1.Identifier
WHERE
	t1.Identifier IS NULL

--EXO3 : Pour chaque civilit� afficher les personnes associ�es, garder les civilit�s sans personne.
SELECT
	*
FROM
	Contact AS t0
RIGHT JOIN
	Civility AS t1 ON t0.IdentifierCivility = t1.Identifier

--EXO4 : Afficher les civilit�s sans personne.
SELECT
	*
FROM
	Contact AS t0
RIGHT JOIN
	Civility AS t1 ON t0.IdentifierCivility = t1.Identifier
WHERE
	t0.Identifier IS NULL

--EXO5 : Pour chaque ville, afficher le nombre d'adresses associ�es. Les villes sans adresse doivent appara�tres.
SELECT
	t0.Name
	,COUNT(*)
FROM
	City AS t0
LEFT JOIN
	Address AS t1 ON t0.Identifier = t1.IdentifierCity
GROUP BY
	t0.Name

--FULL OUTER JOIN = LEFT JOIN + RIGHT JOIN
--Pour r�cup�rer � la fois les enregistrements correspondants et sans correspondances entre deux ensembles.
SELECT
	*
FROM
	Contact AS t0
FULL OUTER JOIN
	Civility AS t1 ON t0.IdentifierCivility = t1.Identifier

SELECT
	*
FROM
	Contact AS t0
FULL OUTER JOIN
	Civility AS t1 ON t0.IdentifierCivility = t1.Identifier
WHERE
	t0.Identifier IS NULL
	OR
	t1.Identifier IS NULL

/*
EXO 1 :	Pour chaque code postal, afficher le nombre de contact
		Les CP sans contact doivent �tre pris en compte.

EXO 2 : Pour chaque CP, Afficher le nomdre de contact
		Ignorer les CP sans contact

EXO 3 : Afficher la moyenne d'�ge (en valeur d�cimal) par CP
		On affiche NULL si pas de contact
		Si une personne n'a pas d'�ge (NULL) on en tient pas compte.

EXO 4 :	Afficher la moyenne d'�ge (en valeur d�cimal) 
			-> par adresse (StreetNumber + RoadType + RoadName + IdentifierCity)
			-> par ville et code postal
			-> par code postal
			-> ainsi que la moyenne d'�ge globale
*/

--EXO 1 :	Pour chaque code postal, afficher le nombre de contact
--			Les CP sans contact doivent �tre pris en compte.
SELECT
	t0.ZipCode
	,COUNT(t2.IdentifierContact) AS Total
FROM
	City AS t0
LEFT JOIN
	Address AS t1 ON t0.Identifier = t1.IdentifierCity
LEFT JOIN
	AddressContact AS t2 ON t1.Identifier = t2.IdentifierAddress
GROUP BY
	t0.ZipCode
--
--EXO 2 :	Pour chaque CP, Afficher le nomdre de contact
--			Ignorer les CP sans contact
SELECT
	t0.ZipCode
	,COUNT(t2.IdentifierContact) AS Total
FROM
	City AS t0
INNER JOIN
	Address AS t1 ON t0.Identifier = t1.IdentifierCity
INNER JOIN
	AddressContact AS t2 ON t1.Identifier = t2.IdentifierAddress
GROUP BY
	t0.ZipCode

--EXO 3 :	Afficher la moyenne d'�ge (en valeur d�cimal) par CP
--			On affiche NULL si pas de contact
--			Si une personne n'a pas d'�ge (NULL) on en tient pas compte.
SELECT
	t0.ZipCode
	,AVG(CAST(t3.Age AS DECIMAL(5,2))) AS Total
FROM
	City AS t0
LEFT JOIN
	Address AS t1 ON t0.Identifier = t1.IdentifierCity
LEFT JOIN
	AddressContact AS t2 ON t1.Identifier = t2.IdentifierAddress
LEFT JOIN
	Contact AS t3 ON t3.Identifier = t2.IdentifierContact
WHERE 
	t3.Age IS NOT NULL
GROUP BY
	t0.ZipCode

--EXO 4 :	Afficher la moyenne d'�ge (en valeur d�cimal) 
--			-> par adresse (StreetNumber + RoadType + RoadName + IdentifierCity)
--			-> par ville et code postal
--			-> par code postal
--			-> ainsi que la moyenne d'�ge globale
SELECT
	t1.FullAddress
	,t0.ZipCode
	,t0.Name
	,AVG(CAST(t3.Age AS DECIMAL(5,2))) AS Total
FROM
	City AS t0
INNER JOIN
(
	SELECT
		t0.Identifier
		,t0.IdentifierCity
		,CONCAT(t0.StreetNumber + N', ', t0.RoadType + N' ', t0.RoadName + N' - ', t1.ZipCode + ' ', t1.Name ) AS FullAddress
	FROM
		Address AS t0
	INNER JOIN
		City AS t1 ON t0.IdentifierCity = t1.Identifier
) AS t1 ON t0.Identifier = t1.IdentifierCity
INNER JOIN
	AddressContact AS t2 ON t1.Identifier = t2.IdentifierAddress
INNER JOIN
	Contact AS t3 ON t3.Identifier = t2.IdentifierContact
WHERE
	t3.Age IS NOT NULL
GROUP BY GROUPING SETS
(
	t0.ZipCode
	,(t0.Name, t0.ZipCode)
	,(t0.Identifier, t1.FullAddress)
	,()
)


SELECT
	t0.Identifier
	,t0.IdentifierCity
	,t1.ZipCode
	,t1.Name
	,CONCAT(t0.StreetNumber + N', ', t0.RoadType + N' ', t0.RoadName + N' - ', t1.ZipCode + ' ', t1.Name )	AS FullAddress
	,AVG(CAST(t3.Age AS DECIMAL(5,2))) OVER (PARTITION BY t1.ZipCode )										AS AverageAgeZipCode
	,AVG(CAST(t3.Age AS DECIMAL(5,2))) OVER (PARTITION BY t1.Name, t1.ZipCode )								AS AverageAgeCityName_ZipCode
	,AVG(CAST(t3.Age AS DECIMAL(5,2))) OVER (PARTITION BY t0.Identifier )									AS AverageAgeAddress
	,AVG(CAST(t3.Age AS DECIMAL(5,2))) OVER ()																AS AverageAgeGeneral
FROM
	Address AS t0
INNER JOIN
	City AS t1 ON t0.IdentifierCity = t1.Identifier
INNER JOIN
	AddressContact AS t2 ON t0.Identifier = t2.IdentifierAddress
INNER JOIN
	Contact AS t3 ON t3.Identifier = t2.IdentifierContact