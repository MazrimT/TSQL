select 
	 x.*
	,_hash = hashbytes('SHA2_512', (select x.* from (values(null))data(bar) for xml auto))
from [databasename].[schemaname].[tableName] x

								
/* 								
you can use the same basic idea to do a datalength on all columns at the same time
datalength = datalength((select x.* from (values(null))data(bar) for xml auto))
								
*/
