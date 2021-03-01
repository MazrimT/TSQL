USE [Database]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[discUsageUpdate] as 

begin

	/********************************************************************

	If table doesn't exists created with:
	
	create table dbo.discUsage (
		DateKey int,
		DatabaseName varchar(255),
		[FileGroup] varchar(255),
		[Disk] varchar(255),
		SchemaName varchar(255),
		TableName varchar(1000),
		TableCreated datetime2(7),
		TableModified datetime2(7),
		TableLastQuery datetime2(7),
		RowCounts bigint,
		TotalSpaceKB bigint,
		UsedSpaceKB bigint,
		UnusedSpaceKB bigint,
		IndexUsageKB bigint,
		_updated datetime2(0)
	) 

	create index NCIX_discUsage_DateKey on dbo.discUsage (DateKey)

	********************************************************************/




	-- declare some variables needed for looping databases
	declare @sql varchar(max)
	declare @i int = 1
	declare @database varchar(255)

	-- make the list of databases to run
	drop table if exists #databases
	select 
		name,
		sort = row_number() over (order by name)
	into #databases
	from sys.databases db
	where db.name not in ('FiftyOne.Foundation SQL', 'tempdb') 
	and db.state_desc = 'ONLINE'


	-- make the temp table to read data into
	drop table if exists #Temp;
	select *
	into #Temp
	from dbo.discUsage
	where 1 = 0

	-- start loop
	while @i <= (select max(sort) from #databases) 
	begin

		-- pick up a name of a database
		set @database = (select name from #databases where sort = @i)
		
		-- make the query to run on that database
		set @sql  = '
			use ' + @database + '

			insert into #Temp
				SELECT 
					 DateKey			= left(convert(char, getdate(), 112), 8)
					,DatabaseName		= ''' + @database + '''
					,[FileGroup]		= fg.name
					,[Disk]				= upper(SUBSTRING(dbf.physical_name, 1, 1))
					,SchemaName			= s.Name
					,TableName			= t.Name
 					,TableCreated		= cast(t.create_date as datetime2)
					,TableModified		= cast(t.modify_date as datetime2)
					,TableLastQuery		= cast(stat.last_date as datetime2)
					,RowCounts			= sum(cast(p.rows as bigint))
					,TotalSpaceKB		= SUM(cast(a.total_pages as bigint)) * 8 / 1000
					,UsedSpaceKB		= SUM(cast(a.used_pages as bigint)) * 8 / 1000
					,UnusedSpaceKB		= (SUM(cast(a.total_pages as bigint)) - SUM(cast(a.used_pages as bigint))) * 8
					,IndexUsageKB		= sum(case when i.index_id > 0 then cast(ps.used_page_count as bigint) else 0 end) * 8
					,_updated			= getdate()
				from sys.tables t with (nolock)
				left join sys.schemas s with (nolock) 
					on t.schema_id = s.schema_id
				left join sys.partitions p with (nolock)
					on p.object_id = t.object_id
				left join sys.dm_db_partition_stats ps with (nolock)
					on ps.object_id = p.object_id
					and ps.partition_id = p.partition_id
				left join sys.indexes i with (nolock)
					on i.object_id = ps.object_id
					and i.index_id = ps.index_id
				left join sys.allocation_units a with (nolock) 
					on a.container_id = p.hobt_id
				left join sys.filegroups fg
					on fg.data_space_id = a.data_space_id
				left join sys.database_files dbf
					on dbf.data_space_id = a.data_space_id
					and dbf.type_desc <> ''LOG''
				left join (
							select
								 object_id
								,last_date = max(date)
							from (
								select 
									s.object_id,
									(select max(v) from (values (s.last_user_seek), (s.last_user_scan), (s.last_user_lookup)) as value(v)) as date
								from sys.dm_db_index_usage_stats s with (nolock)
							) x
							group by object_id
						 ) stat
					on stat.object_id = t.object_id
				group by
					 s.name
					,t.name
					,upper(SUBSTRING(dbf.physical_name, 1, 1))
					,cast(t.create_date as datetime2)
					,cast(t.modify_date as datetime2)
					,cast(stat.last_date as datetime2)
					,fg.name
			'
		-- execute the query 
		exec(@sql)

		-- count up to next database
		set @i = @i + 1

	end



	-- delete old rows for "today" to not get duplication
	delete from dbo.discUsage
	where DateKey = left(convert(char, getdate(), 112), 8)


	-- insert new rows
	insert into dbo.discUsage (DateKey, DatabaseName, [FileGroup], [Disk], SchemaName, TableName, TableCreated, TableModified, TableLastQuery, RowCounts, TotalSpaceKB, UsedSpaceKB, UnusedSpaceKB, IndexUsageKB, _updated)
	Select
		 DateKey
		,DatabaseName	
		,[FileGroup]	
		,[Disk]			
		,SchemaName		
		,TableName		
		,TableCreated	
		,TableModified	
		,TableLastQuery
		,RowCounts		
		,TotalSpaceKB	
		,UsedSpaceKB
		,UnusedSpaceKB	
		,IndexUsageKB
		,_updated
	from #Temp

 		

end;





