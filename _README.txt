PShell_runTSQL

- Powershell Script to Run Multiple T-SQL Scripts on Multiple SQL Server Instances
- The script lets you choose whether to store output in a database table or delimited .CSV file.
- Scripts are/can be dividied into three subcategories; admin/cache/index.

1. Open TSQL_scriptExecution and change the following variables:

$adminServer = "mySqlserver\myInstance"
$reposDB = "myDB"
2. Open SQLServerList.txt and add target servers.
3. Script Execution:

In script root:
.\TSQL_scriptExecution.ps1

Executes with defaults; all output from Scripts\admin and Scripts\cache goes to files (from scripts, log execution results)

PARAMETERS:
- toTable 1 (inserts output into tables)
- logToTable 1 (logs execution result into a table)
- include (commaseparated list to determine which subfolder to look for scripts in - admin,cache, index)

Parameter Defaults:

toTable = 1
logToTable = 1
include = (admin, cache)

E.g: .\scriptExecution.ps1 -logToTable 1
(script output to file, log execution result to table)

.\scriptExecution.ps1 -include index, admin
(scripts in Scripts\index and Scripts\admin are run and all output to files)

4. Adding your own scripts to execute

- Add T-SQL script to the Scripts folder
- If you want script output to tables; add script to create table for the output (NOTE!!! include IF NOT EXIST statement)

FOLDERS:
- Scripts \admin \cache \index (T-SQL scripts to run)
- Scripts_CreateTables (scripts that creates tables to hold output; runs if -toTable =1)
- Script_Output \admin \cache \index (script results output folder)


(Invoke-Sqlcmd2, Write-DataTable: Supporting cmdlets)

FILES:
- TSQL_scriptExecution.ps1 (executes T-SQL scripts)
- SQLServerList.txt (list of target SQL Server instances)
- Create_logScriptExecution.sql (creates execution log table) 
- Some sample T-SQL Scripts in Script subfolders

PARAMETERS:
[String []])
$include = ("admin","cache"),)
[ValidateSet(“admin",”cache”,"index")])

[Int32] $toTable=0, $logToTable=0
