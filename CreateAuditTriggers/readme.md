# CreateAuditTriggers
This script creats a StoredProcedure that will, when run, create an audit-table if one doesn't exist, and then put triggers on a table of choice.  
The triggers will log Inserts, Updates and Deletes into an audit.audit table.  
**Please be adviced that this is done by loads of while loops and is super-not optimized for big data sets that get update frequently.**  
After creating the stored procedure is executed by running:   
  

> exec dbo.CreateAuditTriggers
>     @DatabaseName = [databasename], 
>     @SchemaName = [schemaname], 
>     @TableName = [tablename], 
>     @PrimaryKey = [name of the primarykey column]  
  
@PrimaryKey can be omitted, the StoredProcedure will then try to find it, if there's no primary key on the table it will use the ordinally first column in the table.
the SP can be created in any database (like for example a maintenance database) and run on any table in any database.