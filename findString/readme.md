# findString

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
