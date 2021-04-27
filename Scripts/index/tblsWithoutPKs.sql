
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT DB_NAME() as DBName
,t.name
, CASE OBJECTPROPERTY(t.object_id,'TableHasPrimaryKey')
	WHEN 0 THEN 'NoPK'
	ELSE 'HasPK'
	END AS PKstatus
, CASE OBJECTPROPERTY(t.object_id,'TableHasUniqueCnst')
	WHEN 0 THEN 'NoUniqueCnst'
	ELSE 'HasUniqueCnst'
	END AS UniqueConstraint
, t.create_date
FROM sys.tables t
WHERE t.is_ms_shipped = 0
AND type ='u';

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
