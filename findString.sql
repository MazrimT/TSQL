USE [DatabaseName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[findString] 
	@searchString varchar(max)
as 

begin

	declare @sql varchar(max)
	declare @i int = 1
	declare @database varchar(max)


	/* create temp table save things into */
	drop table if exists #Temp 
	create table #Temp (
		 databaseName varchar(max)
		,schemaName varchar(max)
		,name varchar(max)
		,command varchar(max)
		,type varchar(max)
	)

	/* databases to search */
	drop table if exists #databases
	select 
		name,
		sort = row_number() over (order by name)
	into #databases
	from sys.databases db with (nolock)
	where db.name not in ('tempdb') /* some databases are a bad idea to do this on, does not work for databases with spaces in their names and tempdb is bad to search */

	/* start loop */	
	while @i <= (select max(sort) from #databases) 
	begin

		set @database = (select name from #databases where sort = @i)
		
		set @sql  = '
			use ' + @database + '
			insert into #Temp
			select distinct
				*
			from (

					SELECT distinct
						 databaseName				= ''' + @database + '''
						,schemaName					= s.name
						,name						= o.name
						,command					= null
						,type						= case 
															when cast(OBJECTPROPERTYEX(com.id, ''BaseType'') as varchar(10)) = ''P'' then ''Procedure body''
															when cast(OBJECTPROPERTYEX(com.id, ''BaseType'') as varchar(10)) = ''F'' then ''Function body''
															when cast(OBJECTPROPERTYEX(com.id, ''BaseType'') as varchar(10)) = ''V'' then ''View body''
															else ''Unknown body''
													  end
					FROM SYSCOMMENTS com  with (nolock)
					join sys.objects o  with (nolock)
						on o.object_id = com.id
					join sys.schemas s  with (nolock)
						on s.schema_id = o.schema_id
					where com.text like ''%' + @searchString + '%''

					union all
					select
						 databaseName				= ''' + @database + '''
						,schemaName					= r.ROUTINE_SCHEMA
						,name						= r.ROUTINE_NAME
						,command					= null
						,type						= case 
														when r.ROUTINE_TYPE = ''PROCEDURE'' then ''Procedure name''
														when r.ROUTINE_TYPE = ''FUNCTION'' then ''Function name''
														else r.ROUTINE_TYPE
													 end															
					from INFORMATION_SCHEMA.ROUTINES r  with (nolock)
					where r.ROUTINE_NAME like ''%' + @searchString + '%''

					union all
					select distinct
						 databaseName				= ''' + @database + '''
						,schemaName					= v.TABLE_SCHEMA
						,name						= v.TABLE_NAME
						,command					= null
						,type						= ''View name''
					from INFORMATION_SCHEMA.VIEWS v  with (nolock)
					where v.TABLE_NAME like ''%' + @searchString + '%''

					union all
					select distinct
						 databaseName				= ''' + @database + '''
						,schemaName					= t.TABLE_SCHEMA
						,name						= t.TABLE_NAME
						,command					= null
						,type						= ''Table name''
					from INFORMATION_SCHEMA.TABLES t  with (nolock)
					where t.TABLE_NAME like ''%' + @searchString + '%''
					and t.TABLE_TYPE = ''BASE TABLE''

					union all
					select distinct
						 databaseName				= ''' + @database + '''
						,schemaName					= c.TABLE_SCHEMA
						,name						= c.TABLE_NAME + '' - '' + c.COLUMN_NAME
						,command					= null
						,type						= ''Column name''
					from INFORMATION_SCHEMA.COLUMNS c  with (nolock)
					where c.COLUMN_NAME like ''%' + @searchString + '%''
				) x
			'


		print @sql
		exec(@sql)

		set @i = @i + 1

	end
	



	/*************************************

		sök igenom alla schedulerade jobb

	*************************************/

	set @sql  = '
		insert into #Temp
		select
			 databaseName		= ''Jobs''
			,schemaName			= ''''
			,name				= j.name
			,command			= null
			,type				= ''Job name''
		from msdb.dbo.sysjobs j  with (nolock)
		where j.name like ''%' + @searchString + '%''
		'
	exec (@sql)

	set @sql = '
		insert into #Temp
		select
			 databaseName		= ''Jobs''
			,schemaName			= ''''
			,name				= j.Name
			,command			= null
			,type				= ''Job description''
		from msdb.dbo.sysjobs j with (nolock)
		where j.description like ''%' + @searchString + '%''
		'
	exec (@sql)

	set @sql = '
		insert into #Temp
		select
			 databaseName		= ''Jobs''
			,schemaName			= ''''
			,name				= jb.name + '' - '' + cast(j.step_id as varchar(10)) + '' - '' + j.step_name
			,command			= j.command
			,type				= ''Jobstep name''
		from msdb.dbo.sysjobsteps j with (nolock)
		join msdb.dbo.sysjobs jb with (nolock)
			on jb.job_id = j.job_id
		where j.step_name like ''%' + @searchString + '%''
	'

	set @sql = '
		insert into #Temp
		select
			 databaseName		= ''Jobs''
			,schemaName			= ''''
			,name				= jb.name + '' - '' + cast(j.step_id as varchar(10)) + '' - '' + j.step_name
			,command			= j.command
			,type				= ''Jobstep command''
		from msdb.dbo.sysjobsteps j  with (nolock)
		join msdb.dbo.sysjobs jb with (nolock)
			on jb.job_id = j.job_id
		where j.command like ''%' + @searchString + '%''
		'
	exec (@sql)




select
	* 
from #Temp
order by
	 databasename
	,type
	,schemaName
	,name



end;
