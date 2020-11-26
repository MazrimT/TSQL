# TSQL

Just some T SQL (Microsoft SQL Server) script I've made/used over the years.

## CreateAuditTriggers
This script creats a StoredProcedure that will, when run, create an audit-table if one doesn't exist, and then put triggers on a table of choice.  
The triggers will log Inserts, Updates and Deletes into an audit.audit table.  
**Please be adviced that this is done by loads of while loops and is super-not optimized for big data sets that get update frequently.**  
After creating the stored procedure is executed by running:   
  
> use [DatabaseName]  
> exec dbo.CreateAuditTriggers @SchemaName = [schemaname], @TableName = [tablename], @PrimaryKey = [name of the primarykey column]  
  
@PrimaryKey can be omitted, the StoredProcedure will then try to find it, if there's no primary key on the table it will use the ordinally first column in the table.
