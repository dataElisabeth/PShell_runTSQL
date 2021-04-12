SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

CREATE TABLE #tempTotal  
  
(  
DatabaseName varchar(255),  
Field VARCHAR(255),  
Value VARCHAR(255)  
)  
CREATE TABLE #temp  
(  
ParentObject VARCHAR(255),  
Object VARCHAR(255),  
Field VARCHAR(255),  
Value VARCHAR(255)  
)  
EXECUTE sp_MSforeachdb '  
INSERT INTO #temp EXEC(''DBCC DBINFO ( ''''?'''') WITH TABLERESULTS,no_infomsgs'')  
INSERT INTO #tempTotal (Field, Value, DatabaseName)  
SELECT Field, Value, ''?'' FROM #temp  
TRUNCATE TABLE #temp';  
;WITH cte as  
(  
SELECT  
ROW_NUMBER() OVER(PARTITION BY DatabaseName, Field ORDER BY Value DESC) AS rn,  
DatabaseName,  
Value  
FROM #tempTotal t1  
WHERE (Field = 'dbi_dbccLastKnownGood')  
)  
SELECT   COALESCE(SERVERPROPERTY('InstanceName'),@@SERVERNAME) AS instance,
DatabaseName,  
Value as dbccLastKnownGood,
	DATEDIFF(dd, CAST(Value AS datetime), GetDate()) AS DaysSinceGoodCheckDB,
	DATEDIFF(hh, CAST(Value AS datetime), GetDate()) AS HoursSinceGoodCheckDB
FROM cte  
WHERE (rn = 1)  
ORDER BY DaysSinceGoodCheckDB DESC
DROP TABLE #temp  
DROP TABLE #tempTotal  


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF

