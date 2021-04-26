#weird weird output using csv.

# This script Executes all scripts in .\Scripts\ on all SQL Server instances in  \SQLServerList.txt 
# and outputs to .\Script_output - see VARIABLES  below\

param([Int32]  $createTables = 0, $toTable=0, $logToTable =0) 
 
Set-Location $PSScriptRoot

import-module ".\Write-DataTable\Write-DataTable.psm1"
import-module  ".\Invoke-Sqlcmd2\Invoke-Sqlcmd2.psm1"

# VARIABLES
# 1. $adminServer and $reposDB- the server and database to store result when -toTable OR logToTable  =1
# 2. $instanceNameList - default = "SQLServerList.txt". List of SQL Server instances to run scripts on.
# 3. $ScriptDirectory - default = .\Scripts. Points to directory with *.sql script files.
# 4. $createTableScripts - default =.\Scripts_createTables. Creates tables (IF NOT EXISTS)  to store result when -toTable = 1.


# NOTE!!! If you want to filter on script name, edit and comment out: "-Filter *<filter phrase>k*.sql "

# If you want to run from Windows PS Shell, the following two lines of code needs to be run first
# Add-PSSnapin SqlServerCmdletSnapin100
# Add-PSSnapin SqlServerProviderSnapin100

# 1. Must change! Name the admin server and database
$adminServer = "someserver\someinstance"
$reposDB = "admin"

# 2. (optional): Change path to .txt file with list of servers
$instanceNameList = Get-Content   ($PSScriptRoot + "\SQLServerList.txt")

# 3 (optional).: Change path to point to directory with script files to run and  output directory
$ScriptDirectory = $PSScriptRoot + ".\Scripts\"
$outputpath = $PSScriptRoot + ".\Scripts_output\" 

$createTableScripts = $PSScriptRoot + ".\Scripts_CreateTables\"  #Scripts to create tables to hold output if applic.

$tblLogScriptExec = ".\CREATE_logScriptExecution.sql"  # Script to create log table for execution result

# Dealing with parameter choices 
if ($toTable  -eq 1) 
    {write-host ("Storing script output on: " + $adminserver + " in database " + $reposDB)
        foreach ($s in Get-ChildItem -path $createTableScripts | sort-object -desc )
                    {
                    #write-host($s)
                    Invoke-Sqlcmd2 -ServerInstance $adminServer -database $reposDB  -InputFile $s.fullname
                    }
               
    } 
        else 
        {
        write-host("Storing script output to file in: " + $outputpath)
        }

if ($logToTable  -eq 1) 
    {
    write-host $tblLogScriptExec
     write-host ("Storing log execution result on " +  $adminserver + " in database " + $reposDB)
     Invoke-Sqlcmd2 -ServerInstance $adminServer  -Database $reposDB -InputFile $tblLogScriptExec
    } 
        else 
        {
        write-host("Storing log execution result to file " + "ScriptExec_Log_yyyy-mm-dd.txt")
        }

# Start of loop through all $instanceName items in SQLServerList.txt.

foreach($instanceName in $instanceNameList)

{
  Write-Host "Starting on "  $instanceName
  Try
  {

    # Loop through and execute all .sql files($f)  in $ScriptDirectory on $instanceName 
    # (comment out next line to use  -Filter
         
    # foreach ($f in Get-ChildItem -path $ScriptDirectory -Filter *back*.sql  | sort-object -desc ) 

    foreach ($f in Get-ChildItem -path $ScriptDirectory | sort-object -desc )
    
	{ 
        Try
        {
            $outputInstance = $instancename -replace '\\','_'
            $outputfile = $f.BaseName + $outputInstance + '.txt'
            $outputfilepath = $outputpath + $outputfile
            
            if ($toTable -eq 0) 
                {
                #Write-Host "Script output to directory: " $outputpath
                #Invoke-Sqlcmd2 -ServerInstance $instanceName -InputFile $f.fullname | Format-Table -autosize | Out-File  -filePath $outputfilepath #fixedlength output
                Invoke-Sqlcmd2 -ServerInstance $instanceName -InputFile $f.fullname |  Export-Csv $outputfilepath  -Delimiter "~" -NoTypeInformation
                }              
                else {
                        #Write-Host "Script output to server: " $adminServer
                        $tblName = "res" + $f.basename
 		                $dt = Invoke-Sqlcmd2 -ServerInstance $instanceName -InputFile $f.fullname -As 'DataTable'
                        Write-DataTable -ServerInstance $adminServer -Database "$reposDB" -TableName $tblName -Data $dt
                        }
            if ($logToTable -eq 0)
                {
               
                #Write-Host "Logging script execution to: " ScriptExec_Log_$(get-date -f yyyy-MM-dd).txt
                $logRecord = Get-Date -Format "yyyy-MM-dd HH:mm:ss".ToString()
               
                $logRecord = $logRecord + "   " + $instanceName + "   " + $f + "   Successful: " + $?
                $logRecord | Out-File ScriptExec_Log_$(get-date -f yyyy-MM-dd).txt -append
               
                }
                else  {
                        #Write-Host "Logging script execution to: " $adminServer
			            $query = "INSERT INTO logScriptExecution (targetServer, Script, checkDate,Success) values ('$instanceName', '$f', DEFAULT,'$?')"
			            Invoke-sqlcmd -ServerInstance $adminServer -Database "$reposDB" -query $query  | ft
                        }
      }
        Catch
        {
            Set-Location $PSScriptRoot
            $myErr = "$(get-date -Format u)  Error running $f on $instancename  $_ "
            $Exception = $_.Exception.Message

            #Writing error to host            
            write-host $myErr
            
            if ($logToTable -eq 1) # Insert row in log table for erroring script            
                {
                Invoke-Sqlcmd -Serverinstance $adminServer -Database $reposDB -Query "INSERT INTO logScriptExecution (targetServer, Script, checkDate, Success) values (`'$instanceName'`, `'$f'`, DEFAULT,`'$Exception'`)"
                }
                else # Writing error to file
                    {
                    $myErr| Out-File ScriptExec_Errors_$(get-date -f yyyy-MM-dd).txt -append
                    }
            continue
        }
        
	} # End of Foreach Get-ChildItem -path $ScriptDirectory (all scripts)

}
Catch
        {
            Set-Location $PSScriptRoot
            $myErr = "$(get-date -Format u)  Error running $f on $instancename  $_ "
            $Exception = $_.Exception.Message

            #Writing error to host            
            write-host $myErr
            
            if ($logToTable -eq 1) # Insert row in log table for erroring script            
                {
                Invoke-Sqlcmd -Serverinstance $adminServer -Database $reposDB -Query "INSERT INTO logScriptExecution (targetServer, Script, checkDate, Success) values (`'$instanceName'`, `'$f'`, DEFAULT,`'$Exception'`)"
                }
                else # Writing error to file
                    {
                    $myErr| Out-File ScriptExec_Errors_$(get-date -f yyyy-MM-dd).txt -append
                    }
            continue
        }
      
Write-Host "Finished on " $instanceName
} # End of foreach($instanceName in $instanceNameList (all servers)
