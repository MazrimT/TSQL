# TSQL

Just some T SQL (Microsoft SQL Server) script I've made/used over the years.
Mostly things I've searched for on different websites by never found good anwsers to so I had to create them myself.

## CreateAuditTriggers
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

## urlToBaseUrl
parses any correctly formated url and returns the url without prefix, ports and stuff after / (also works on "2nd level domains" such as "something.co.uk")

usage:  
exec dbo.urlToBaseUrl 'someUrl.com'  
or
select 
  BaseUrl = dbo.urlToBaseUrl(url) 
from dbo.TablesThatHasUrlColumn

Example:  
htps://subdomain.domain.com:443/somesite/subsite/somepage.html -> subdomain.domain.com

## urlToDomain
parses any correctly formated url and returns the domain. (also works on "2nd level domains" such as "something.co.uk")  
  
usage:  
exec dbo.urlToDomain 'someUrl.com'  
or
select 
  Domain = dbo.urlToDomain(url) 
from dbo.TablesThatHasUrlColumn
  
Examples:  
https://subdomain.domain.com:443/somesite/subsite/somepage.html -> domain.com  
https://subdomain.domain.co.uk:443/somesite/subsite/somepage.html -> domain.co.uk  

## urlToTopDomain
parses any correctly formated url and returns the top-domain. (also works on "2nd level domains" such as "something.co.uk")  
  
usage:  
exec dbo.urlToTopDomain 'someUrl.com'  
or
select 
  TopDomain = dbo.urlToTopDomain(url) 
from dbo.TablesThatHasUrlColumn

Examples:  
https://subdomain.domain.com:443/somesite/subsite/somepage.html -> com  
https://subdomain.domain.co.uk:443/somesite/subsite/somepage.html -> co.uk

## AD_memberships
assumes access to copy of users and groups from an active directory and creates an easy to use "memberships" cross table.

## TableWithAutoNumber
How to create a table that has a "number" with a prefix that counts up automatically

## discUsage
Creates a stored procedure that when run will look through all databases and record metadata about tables such as discusage, index usage, last queried, last updated.

## DatabaseRolesAndAccess
Creates a stored procedure that when run will look through all databases and record who has access to them. since some of these are group access it also checks who is in what group.
