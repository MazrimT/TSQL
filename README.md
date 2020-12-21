# TSQL

Just some T SQL (Microsoft SQL Server) script I've made/used over the years.
Mostly things I've searched for on different websites by never found good anwsers to so I had to create them myself.

## CreateAuditTriggers
This script creats a StoredProcedure that will, when run, create an audit-table if one doesn't exist, and then put triggers on a table of choice.  
The triggers will log Inserts, Updates and Deletes into an audit.audit table.  
**Please be adviced that this is done by loads of while loops and is super-not optimized for big data sets that get update frequently.**  
After creating the stored procedure is executed by running:   
  

> exec dbo.CreateAuditTriggers @DatabaseName = [databasename], @SchemaName = [schemaname], @TableName = [tablename], @PrimaryKey = [name of the primarykey column]  
  
@PrimaryKey can be omitted, the StoredProcedure will then try to find it, if there's no primary key on the table it will use the ordinally first column in the table.
the SP can be created in any database (like for example a maintenance database) and run on any table in any database.
  
## FullTableHash
Small script that creates a hash for the full table without having to specify each column.  
Fairly fast (and you can change the SHA2_512 to whichever hashbytes you need.  

## findString
Creates a StoredProcedure that searches the whole server for a string.  
It searches for the string being contained in :
* tablen names
* column names
* viewn names
* view column names
* view code
* stored procedure names
* stored procedure code
* function names
* function code
* job names
* job descriptions
* job step names
* job commands
  
can not search SSIS packages.

execute with:  
> exec dbo.findString 'string to find'

## ActiveQueries
Lists currently running queries and gives some good info about them.
