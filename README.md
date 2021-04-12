## PShell_runTSQL
Powershell Script to Run Multiple T-SQL Scripts on Multiple SQL Server Instances

The script lets you choose whether to store output in a database table or output to file.

### 1. Open TSQL_scriptExecution and change the following variables:

$adminServer = "mySqlserver\myInstance"
$reposDB = "myDB"

### 2. Open SQLServerList.txt and add target servers.

### 3. SCRIPT EXECUTION:
In script root:
.\TSQL_scriptExecution.ps1

Executes with defaults; all output  goes to files (from scripts, log execution results)

#### PARAMETERS;
-toTable 1 	Inserts output into tables
-logToTable 1	Logs execution result into a table

E.g:
.\scriptExecution.ps1 -logToTable 1	Script output to file, log execution result to table

### 4. ADDING SCRIPTS TO EXECUTE
1. Add T-SQL script to the Scripts folder
2. Add script to create table to store output from new script (include IF NOT EXIST statement)

#### FOLDERS:
Scripts: 		T-SQL scripts to run
Scripts_CreateTables:	Scripts that creates tables to hold output (runs if -toTable =1)
Scripts_Output:		Script results output folder

(Invoke-Sqlcmd2, Write-DataTable: Supporting cmdlets)

#### FILES:
TSQL_scriptExecution.ps1		Executes T-SQL scripts
SQLServerList.txt			List of target SQL Server instances
CreateTbl_tblLogScriptExecution.sql	Creates execution log table

#### PARAMETERS:
param([Int32] $toTable=0, $logToTable=0) 

