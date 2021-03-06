SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT
   (CASE WHEN ([database_id] = 32767)
       THEN 'Resource Database'
       ELSE DB_NAME ([database_id]) END) AS [DatabaseName],
   COUNT (*) * 8 / 1024 AS [MBUsed],
   SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [MBEmpty]
FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id]
ORDER BY MBEmpty dESC;
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
