USE [DatabaseName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[CreateAuditTriggers]
	 @SchemaName varchar(100)					/* mandatory */
	,@TableName varchar(255)					/* mandatory */
	,@PrimaryKey varchar(255)	= 'unknown'		/* if primary key is not supplied try to find it below */
as 
begin

	declare @sql nvarchar(max)					/* make the variable to put dynamic sql into */

	/************************************************************************************

		check if the audit schema exists, if not create it

	************************************************************************************/

	if not exists (select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME = 'audit')
	begin
		set @sql = 'CREATE SCHEMA audit AUTHORIZATION dbo;'
		exec(@sql)
	end

	/************************************************************************************

		check that the audit table exists, if not create it.

	************************************************************************************/
	 
	if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'audit' and TABLE_NAME = 'audit')
	begin
		set @sql = '
			create table audit.audit (
					 AuditId		bigint identity(1,1) PRIMARY KEY
					,AuditAction	varchar(10)
					,AuditGroupId	UNIQUEIDENTIFIER
					,AuditTs		datetime2
					,SchemaName		varchar(255)
					,TableName		varchar(255)
					,PrimaryKey		varchar(255)
					,RowId			varchar(255)
					,ColumnName		varchar(255)
					,OldValue		nvarchar(max)
					,NewValue		nvarchar(max)
					,Username		varchar(255)
				);
			'
		exec(@sql)
	end 

	/************************************************************************************************************************************************

		if @PrimaryKey is not set then check if there's a primary key
		if there's nothing set when running the SP we check if there's a PK if not we pick the ordinally first column in the table

	************************************************************************************************************************************************/

	if @PrimaryKey = 'unknown'
	begin

		set @PrimaryKey = isnull(
							(
								select 
									ccu.COLUMN_NAME
								from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
								join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
									on ccu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
								where tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
								and tc.CONSTRAINT_SCHEMA = @SchemaName
								and tc.TABLE_NAME = @TableName
							),
							(
								select 
									c.COLUMN_NAME 
								from INFORMATION_SCHEMA.COLUMNS c
								where c.TABLE_SCHEMA = @SchemaName
								and c.TABLE_NAME = @TableName
								and c.ORDINAL_POSITION = 1
							)
						)
	end 

	/************************************************************************************

		Small delay, if this is used automatically after creating a table 
		this just makes sure the table is fully created before creating trigger

	************************************************************************************/

	waitfor delay '00:00:01'

	/************************************************************************************

		make the UPDATE trigger

	************************************************************************************/

	set @sql = N'create trigger '+@SchemaName+'.'+@TableName+'_update		
				on '+@SchemaName+'.'+@TableName+'
				after UPDATE
				as begin
					set NOCOUNT ON;

					declare @AuditGroupId varchar(255) = newid();

					drop table if exists #inserted;
					select 
						*
					into #inserted 
					from inserted;
					
					drop table if exists #deleted
					select
						* 
					into #deleted 
					from deleted;

					drop table if exists #columns
					select 
						COLUMN_NAME
					into #columns
					from INFORMATION_SCHEMA.COLUMNS 
					where TABLE_NAME = '''+@TableName+'''
					and TABLE_SCHEMA = '''+@SchemaName+'''
					and COLUMN_NAME <> '''+@PrimaryKey+'''
					;

					declare @columnName varchar(100);
					declare @sql nvarchar(max);

					while exists (select * from #columns)
					begin
						set @columnName = (select top 1 COLUMN_NAME from #columns);
		
						set @sql = N''insert into audit.Audit (AuditGroupId, AuditAction, AuditTs, SchemaName, TableName, PrimaryKey, RowId, ColumnName, OldValue, NewValue, Username)
									select
										 AuditGroupId		= cast(''''''+@AuditGroupId+'''''' as uniqueidentifier)
										,AuditAction		= ''''UPDATE''''
										,AuditTs			= getDate()
										,SchemaName			= '''''+@SchemaName+'''''
										,TableName			= '''''+@TableName+'''''
										,PrimaryKey			= '''''+@PrimaryKey+'''''
										,RowId				= i.'+@PrimaryKey+'
										,ColumnName			= ''''''+@columnName+''''''
										,OldValue			= d.''+@columnName+''
										,NewValue			= i.''+@columnName+''
										,Username			= SYSTEM_USER
									from #inserted i
									join #deleted d
										on i.'+@PrimaryKey+' = d.'+@PrimaryKey+'
										and i.''+@columnName+'' <> d.''+@columnName+''
									;
									'';

						exec (@sql);

						set @sql = N''delete from #columns where COLUMN_NAME = ''''''+@columnName+'''''';'';

						exec (@sql);
			
					end
				end
		'

	exec (@sql)

	/************************************************************************************

		make the INSERT trigger

	************************************************************************************/

	set @sql = N'create trigger '+@SchemaName+'.'+@TableName+'_insert
				on '+@SchemaName+'.'+@TableName+'
				after INSERT
				as begin
					set NOCOUNT ON;

					declare @AuditGroupId varchar(255) = newid();

					drop table if exists #inserted;
					select 
						*
					into #inserted 
					from inserted;

					drop table if exists #columns
					select 
						COLUMN_NAME
					into #columns
					from INFORMATION_SCHEMA.COLUMNS 
					where TABLE_NAME = '''+@TableName+'''
					and TABLE_SCHEMA = '''+@SchemaName+'''
					and COLUMN_NAME <> '''+@PrimaryKey+'''
					;

					declare @columnName varchar(100);
					declare @sql nvarchar(max);

					while exists (select * from #columns)
					begin
						set @columnName = (select top 1 COLUMN_NAME from #columns);
		
						set @sql = N''insert into audit.Audit (AuditGroupId, AuditAction, AuditTs, SchemaName, TableName, PrimaryKey, RowId, ColumnName, OldValue, NewValue, Username)
									select
										 AuditGroupId		= cast(''''''+@AuditGroupId+'''''' as uniqueidentifier)
										,AuditAction		= ''''INSERT''''
										,AuditTs			= getDate()
										,SchemaName			= '''''+@SchemaName+'''''
										,TableName			= '''''+@TableName+'''''
										,PrimaryKey			= '''''+@PrimaryKey+'''''
										,RowId				= i.'+@PrimaryKey+'
										,ColumnName			= ''''''+@columnName+''''''
										,OldValue			= null
										,NewValue			= i.''+@columnName+''
										,Username			= SYSTEM_USER
									from #inserted i
									;
									'';

						exec (@sql);

						set @sql = N''delete from #columns where COLUMN_NAME = ''''''+@columnName+'''''';'';

						exec (@sql);
			
					end
				end
		'

	exec (@sql)



	/************************************************************************************

		make the DELETE trigger

	************************************************************************************/

	set @sql = N'create trigger '+@SchemaName+'.'+@TableName+'_delete
				on '+@SchemaName+'.'+@TableName+'
				after DELETE
				as begin
					set NOCOUNT ON;

					declare @AuditGroupId varchar(255) = newid();

					drop table if exists #deleted;
					select 
						*
					into #deleted 
					from deleted;

					drop table if exists #columns
					select 
						COLUMN_NAME
					into #columns
					from INFORMATION_SCHEMA.COLUMNS 
					where TABLE_NAME = '''+@TableName+'''
					and TABLE_SCHEMA = '''+@SchemaName+'''
					and COLUMN_NAME <> '''+@PrimaryKey+'''
					;

					declare @columnName varchar(100);
					declare @sql nvarchar(max);

					while exists (select * from #columns)
					begin
						set @columnName = (select top 1 COLUMN_NAME from #columns);
		
						set @sql = N''insert into audit.Audit (AuditGroupId, AuditAction, AuditTs, SchemaName, TableName, PrimaryKey, RowId, ColumnName, OldValue, NewValue, Username)
									select
										 AuditGroupId		= cast(''''''+@AuditGroupId+'''''' as uniqueidentifier)
										,AuditAction		= ''''DELETE''''
										,AuditTs			= getDate()
										,SchemaName			= '''''+@SchemaName+'''''
										,TableName			= '''''+@TableName+'''''
										,PrimaryKey			= '''''+@PrimaryKey+'''''
										,RowId				= d.'+@PrimaryKey+'
										,ColumnName			= ''''''+@columnName+''''''
										,OldValue			= d.''+@columnName+''
										,NewValue			= null
										,Username			= SYSTEM_USER
									from #deleted d
									;
									'';

						exec (@sql);

						set @sql = N''delete from #columns where COLUMN_NAME = ''''''+@columnName+'''''';'';

						exec (@sql);
			
					end
				end
		'

	exec (@sql)






end
