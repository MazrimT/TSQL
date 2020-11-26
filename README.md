# TSQL

Just some T SQL (Microsoft SQL Server) script I've made/used over the years.

## CreateAuditTriggers
this script creats a StoredProcedure that will, when run, create an audit-table if one doesn't exist, and then put triggers on a table of choice.
The triggers will log Inserts, Updates and Deletes into an audit.audit table.
*Please be adviced that this is done by loads of while loops and is super-not optimized for big data sets that get update frequently.*
