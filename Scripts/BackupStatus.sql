SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
 COALESCE(SERVERPROPERTY('InstanceName'),@@SERVERNAME) AS instance,
D.[name] AS [database_name]
, D.[recovery_model_desc]
, BS1.[last_log_backup_date]
, BS2.[last_diff_backup_date]
, BS3.[last_data_backup_date]
--, bmf2.physical_device_name as FullBackupLoc
--, bmf1.physical_device_name as LogBackupLoc
, getdate()

FROM 
sys.databases D LEFT JOIN  
( 
   SELECT BS.[database_name],  
   MAX(BS.[backup_finish_date]) AS [last_log_backup_date]  

   FROM msdb.dbo.backupset BS  
   WHERE BS.type = 'L'  
   GROUP BY BS.[database_name]
   ) BS1  
ON D.[name] = BS1.[database_name] 
LEFT JOIN  
( 
   SELECT BS.[database_name],  
   MAX(BS.[backup_finish_date]) AS [last_diff_backup_date]  

   FROM msdb.dbo.backupset BS  
   WHERE BS.type = 'I'  
   GROUP BY BS.[database_name] 
) BS2  
ON D.[name] = BS2.[database_name] 
LEFT JOIN  
( 
   SELECT BS.[database_name],  
   MAX(BS.[backup_finish_date]) AS [last_data_backup_date]  

   FROM msdb.dbo.backupset BS  
   WHERE BS.type = 'D'  
   GROUP BY BS.[database_name] 
) BS3  
ON D.[name] = BS3.[database_name] 
WHERE d.is_read_only =0
AND is_in_standby = 0
AND d.state_desc ='ONLINE'
ORDER BY 2,3 DESC,4 DESC

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF


