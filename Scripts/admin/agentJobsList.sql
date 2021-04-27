
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON



SELECT --DISTINCT
 COALESCE(SERVERPROPERTY('InstanceName'),@@SERVERNAME) AS instance,
j.[name],
jh2.[LastRun],
jh2.minStepDuration,
jh2.maxStepDuration,
[Status] = CASE jh.run_status
WHEN 0 THEN 'Failed'
WHEN 1 THEN 'Success'
WHEN 2 THEN 'Retry'
WHEN 3 THEN 'Canceled'
WHEN 4 THEN 'In progress'
END
, (
SELECT COUNT(*) 
FROM msdb.dbo.sysjobhistory sjh
WHERE sjh.run_status = 0
AND sjh.job_id = jh.job_id
AND sjh.instance_id = jh.instance_id) AS NumberOfFailedSteps
,jh.run_date as [Job last run date]
,jh.run_time as [job last run time]
,j.enabled as [Job Enabled]
FROM 
msdb.dbo.sysjobs j
LEFT OUTER JOIN
(
SELECT job_id,
MAX(CAST(
STUFF(STUFF(CAST(jh.run_date as varchar),7,0,'-'),5,0,'-') + ' ' +
STUFF(STUFF(REPLACE(STR(jh.run_time,6,0),' ','0'),5,0,':'),3,0,':') as
datetime)) AS [LastRun]
, MIN(CAST(run_duration/10000 as varchar)  + ':' + CAST(run_duration/100%100 as varchar) + ':' + CAST(run_duration%100 as varchar)) AS MINStepDuration
, MAX(CAST(run_duration/10000 as varchar)  + ':' + CAST(run_duration/100%100 as varchar) + ':' + CAST(run_duration%100 as varchar)) AS MaxStepDuration

FROM
msdb.dbo.sysjobhistory jh
WHERE step_id = 0
GROUP BY job_id
) jh2
ON j.job_id = jh2.job_id
JOIN
msdb.dbo.sysjobhistory jh
ON jh2.job_id = jh.job_id
AND CAST(
STUFF(STUFF(CAST(jh.run_date as varchar),7,0,'-'),5,0,'-') + ' ' +
STUFF(STUFF(REPLACE(STR(jh.run_time,6,0),' ','0'),5,0,':'),3,0,':') as
datetime) = jh2.Lastrun
WHERE jh.step_id = 0
ORDER by [Status]


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF