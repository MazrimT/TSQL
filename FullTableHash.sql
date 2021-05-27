select 
	 x.*
	,_hash = hashbytes('SHA2_512', (select x.* from (values(null))data(bar) for xml auto))
from [databasename].[schemaname].[tableName] x

								
/* 								
had an idea to also be able to use this for datalength for all columns, but problem is it addas all the keys and other things so it will show way bigger size than just the data..
datalength = datalength((select x.* from (values(null))data(bar) for xml auto))
								
*/
