
# This script Executes all scripts in .\Scripts\<include>  on all SQL Server instances in  \SQLServerList.txt 
# and outputs to .\<include>\Script_output
# Please see variables below for must change variables

param(
[String []] 
$include = ("admin","cache"),
 [ValidateSet(“admin",”cache”,"index")] 

[Int32] $toTable=0, $logToTable =0) 

 
Set-Location $PSScriptRoot

import-module ".\Write-DataTable\Write-DataTable.psm1"
import-module  ".\Invoke-Sqlcmd2\Invoke-Sqlcmd2.psm1"

# VARIABLES
# 1. $adminServer and $reposDB- the server and database to store result when -toTable OR logToTable  =1
# 2. $instanceNameList - default = "SQLServerList.txt". List of SQL Server instances to run scripts on.
# 3. $ScriptDirectory - default = .\Scripts. Points to directory with *.sql script files.
# 4. $createTableScripts - default =.\Scripts_createTables. Creates tables (IF NOT EXISTS)  to store result when -toTable = 1.


# NOTE!!! If you want to filter on script name, edit : "-Filter *<filter phrase>*.sql "
# in "foreach ($f in Get-ChildItem -path $scriptSubdir..."

# 1. Must change! Name the admin server and database
$adminServer = "myserver\myinstance"
$reposDB = "dba"

# 2. (optional): Change path to .txt file with list of servers
$instanceNameList = Get-Content   ($PSScriptRoot + "\SQLServerList.txt")

# 3 (optional): Change path to point to directory with script files to run and  output directory
$ScriptDirectory = $PSScriptRoot + ".\Scripts\"
$outputpath = $PSScriptRoot + ".\Script_output\" 

#Scripts to create tables to hold output -toTable = 1 
$createTableScripts = $PSScriptRoot + ".\Scripts_CreateTables\"  

# Script to create log table for execution result if -logToTable = 1
$tblLogScriptExec = ".\CREATE_logScriptExecution.sql"  

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
  foreach ($i in $include)
    {
        
        $scriptSubdir = $ScriptDirectory  + $i
        #write-host $scriptSubdir
        #write-host $newpath
        Write-Host "Running scripts in "  $i

  Try
  {

    # Loop through and execute all .sql files($f)  in $scriptSubdir on $instanceName 
         
    # foreach ($f in Get-ChildItem -path $scriptSubdir -Filter *back*.sql  | sort-object -desc ) 

    foreach ($f in Get-ChildItem -path $scriptSubdir -Filter *.sql | sort-object -desc ) 
    
	{ 
        Try
        {
            $outputInstance = $instancename -replace '\\','_'
            $outputfile = $outputInstance +'_' + $f.BaseName + '.txt'
            
            $outputSubdir = $outputpath  + $i +'\'
            $outputfilepath = $outputSubdir + $outputfile
            

            if ($toTable -eq 0) 
                {
                #Write-Host "Script output to directory: " $outputSubdir
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
        
	} # End of foreach ($f in Get-ChildItem -path $scriptSubdir (scripts in on subfolder))

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
    Write-Host "Finished running " $i " scripts on" $instancename    
      
  } # End of foreach $i in $include (all scripts in all folders)

Write-Host "Finished on " $instanceName
} # End of foreach $instanceName in $instanceNameList (all servers)
