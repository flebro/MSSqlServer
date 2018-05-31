

SELECT
	*
	,t0.Node.ToString()							AS ToString
	,t0.Node.GetLevel() - 1						AS Level
	--IsDescendantOf(othernode) permet de déterminer si un noeud est enfant du noeud othernode
	,t0.Node.IsDescendantOf(t0.ManagerNode)
	--GetAncestor(n) permet de construire un HIERARCHYID pour le parent de niveau n
	,t0.Node.GetAncestor(1).ToString()
FROM
	Resource AS t0

SELECT DISTINCT
	t0.*
	,t0.Node.ToString()
	,AVG(CAST(t1.Age AS DECIMAL(18,2))) OVER (PARTITION BY t0.Identifier) AS Moyenne
FROM
	Resource AS t0 --Noeud parent
LEFT JOIN
	Resource AS t1 ON t1.Node.IsDescendantOf(t0.Node) = 1 --AND t0.Node <> t1.Node --Noeud enfant

--lecture de haut en bas de l'arbre
;WITH Resources AS 
(
	--on commence par sélectionner les noeuds racindes de l'arbre
	SELECT
		t0.Identifier
		,t0.IdentifierManager
		,t0.Identifier									AS RootIdentifier
		,t0.Code
		,t0.Age
		,CAST(0 AS INT)									AS Level
		,CAST(t0.Code AS NVARCHAR(4000))				AS CumulatedCode
		,CAST(	'\' + 
				CAST(t0.Identifier AS NVARCHAR(4000)) + 
				'\' AS NVARCHAR(4000))					AS Identifiers
		,CAST('\' AS NVARCHAR(4000))					AS IdentifierManagers
	FROM
		Resource AS t0
	WHERE
		t0.IdentifierManager IS NULL --Les personnes sans manager
	UNION ALL
	--Ensuite, on va sélectionner les noeuds enfant
	SELECT
		t1.Identifier
		,t0.Identifier												AS IdentifierManager
		,t0.RootIdentifier											AS RootIdentifier
		,t1.Code
		,t1.Age
		,t0.Level + 1												AS Level
		,CAST(t0.CumulatedCode + ',' + t1.Code AS NVARCHAR(4000))	AS CumulatedCode
		,CAST(	t0.Identifiers + 
				CAST(t1.Identifier AS NVARCHAR(4000)) + 
				'\' AS NVARCHAR(4000))								AS Identifiers
		,CAST(t0.Identifiers AS NVARCHAR(4000))					AS IdentifierManagers
	FROM
		Resources AS t0 --Resources représente le manager du noeud en cours
	INNER JOIN
		Resource AS t1 ON t0.Identifier = t1.IdentifierManager --t1 = noeud enfant
)
SELECT DISTINCT
	t0.*
	,AVG(CAST(t1.Age AS decimal(18,2))) OVER (PARTITION BY t0.Identifier)  AS AVG_Age
	--,AVG(CAST(t0.Age AS decimal(18,2))) OVER 
	--	(PARTITION BY t0.IdentifierManager)  AS AVG_Age
	--,AVG(CAST(t0.Age AS decimal(18,2))) OVER 
	--	(PARTITION BY t0.RootIdentifier)  AS AVG_Age_Root
FROM				--Noeud principal
	Resources AS t0 
LEFT JOIN			--Noeud hiérarchique enfant (direct ou indirect) du noeud principal
	Resources AS t1 ON t1.Identifiers LIKE t0.Identifiers + '%'