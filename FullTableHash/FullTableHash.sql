select 
     x.*
    ,_hash = hashbytes('SHA2_512', (select x.* from (values(null))data(bar) for xml auto))
from [databasename].[schemaname].[tableName] x