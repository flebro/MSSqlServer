--lecture de haut en bas de l'arbre
;WITH Resources AS 
(
	--on commence par sélectionner les noeuds racindes de l'arbre
	SELECT
		t0.Identifier
		,t0.IdentifierManager
		,t0.Identifier			AS RootIdentifier
		,t0.Code
		,CAST(t0.Code AS nvarchar)				as CodeCum
		,t0.Age
		,CAST(0 AS INT)			AS Level
		,CAST(CONCAT('\', CAST(t0.Identifier AS nvarchar(4000)), '\') as nvarchar(4000)) as Identifiers
		,CAST('\' as nvarchar(4000)) as IdentifierManagers
	FROM
		Resource AS t0
	WHERE
		t0.IdentifierManager IS NULL --Les personnes sans manager
	UNION ALL
	--Ensuite, on va sélectionner les noeuds enfant
	SELECT
		t1.Identifier
		,t0.Identifier				AS IdentifierManager
		,t0.RootIdentifier			AS RootIdentifier
		,t1.Code
		,CAST(CONCAT(t0.CodeCum, ', ', t1.Code) As nvarchar) as CodeCum
		,t1.Age
		,t0.Level + 1			AS Level
		,CAST(CONCAT(t0.Identifiers, CAST(t1.Identifier as nvarchar(4000)), '\') as nvarchar(4000)) as Identifiers
		,t0.Identifiers as IdentifierManagers
	FROM
		Resources AS t0 --Resources représente le manager du noeud en cours
	INNER JOIN
		Resource AS t1 ON t0.Identifier = t1.IdentifierManager --t1 = noeud enfant
)
SELECT DISTINCT 
	parents.*,
	AVG(CAST(enfants.age as int)) OVER (PARTITION BY parents.Identifier)
FROM 
	Resources AS parents
left join Resources as enfants on enfants.Identifiers LIKE parents.Identifiers + '%'
go


