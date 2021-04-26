## PShell_runTSQL

* Powershell Script to Run Multiple T-SQL Scripts on Multiple SQL Server Instances

* The script lets you choose whether to store output in a database table or delimited .CSV file.

### 1. Open TSQL_scriptExecution and change the following variables:

$adminServer = "mySqlserver\myInstance" <br />
$reposDB = "myDB"

### 2. Open SQLServerList.txt and add target servers.

### 3. Script Execution:
In script root:<br />
.\TSQL_scriptExecution.ps1

Executes with defaults; all output  goes to files (from scripts, log execution results)

##### PARAMETERS;
-toTable 1			(inserts output into tables) <br />
-logToTable 1		(logs execution result into a table)

E.g:
.\scriptExecution.ps1 -logToTable 1	<br />
(script output to file, log execution result to table)

### 4. Adding your own scripts to execute
1. Add T-SQL script to the Scripts folder <br />
2. If you want script output to tables; add script to create table for the output (Note!!! include IF NOT EXIST statement)

#### Folders:
Scripts 							(T-SQL scripts to run)<br />
Scripts_CreateTables (scripts that creates tables to hold output; runs if -toTable =1)<br />
Scripts_Output (script results output folder) <br />

(Invoke-Sqlcmd2, Write-DataTable: Supporting cmdlets)

#### Files:
TSQL_scriptExecution.ps1 (executes T-SQL scripts)<br />
SQLServerList.txt (list of target SQL Server instances)<br />
Create_logScriptExecution.sql (creates execution log table)

#### Parameters:
param([Int32] $toTable=0, $logToTable=0) 

