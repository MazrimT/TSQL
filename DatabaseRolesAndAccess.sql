USE [Database]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[DatabaseRolesAndAccess] as 

begin

	/********************************************************

		Get roles for each database

	********************************************************/

	drop table if exists #roles
	create table #roles (
		 [DatabaseName]			varchar(255)
		,[UserName]				varchar(255)
		,[UserType]				varchar(255)
		,[DatabaseUserName] 	varchar(255)
		,[Role]   				varchar(255)
		,[PermissionType]		varchar(255)
		,[PermissionState]  	varchar(255)
		,[ObjectType]  			varchar(255)
		,[ObjectName]			varchar(255)
		,[ColumnName] 			varchar(255)
	)



	declare @sql varchar(max)
	declare @i int = 1
	declare @database varchar(255)

	drop table if exists #databases
	select 
		name,
		sort = row_number() over (order by name)
	into #databases
	from sys.databases db
	where db.state_desc = 'ONLINE'




	/* starta loop */
	while @i <= (select max(sort) from #databases) 
	begin


		set @database = (select name from #databases where sort = @i)
		
		set @sql  = '
			use ' + @database + '

			insert into #roles
			select
				[DatabaseName] = ''' + @database +  ''',
				[UserName] = CASE princ.[type] 
								WHEN ''S'' THEN princ.[name]
								WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
							 END,
				[UserType] = CASE princ.[type]
								WHEN ''S'' THEN ''SQL User''
								WHEN ''U'' THEN ''Windows User''
							 END,  
				[DatabaseUserName] = princ.[name],       
				[Role] = null,      
				[PermissionType] = perm.[permission_name],       
				[PermissionState] = perm.[state_desc],       
				[ObjectType] = obj.type_desc,--perm.[class_desc],       
				[ObjectName] = OBJECT_NAME(perm.major_id),
				[ColumnName] = col.[name]
			FROM sys.database_principals princ  with (nolock)
			LEFT JOIN sys.login_token ulogin with (nolock)
				on princ.[sid] = ulogin.[sid]
			LEFT JOIN sys.database_permissions perm with (nolock)
				ON perm.[grantee_principal_id] = princ.[principal_id]
			LEFT JOIN sys.columns col with (nolock)
				ON col.[object_id] = perm.major_id 
				AND col.[column_id] = perm.[minor_id]
			LEFT JOIN sys.objects obj with (nolock)
				ON perm.[major_id] = obj.[object_id]
			WHERE 
				princ.[type] in (''S'',''U'')
			UNION
			--List all access provisioned to a sql user or windows user/group through a database or application role
			SELECT  
				[DatabaseName] = ''' + @database +  ''',
				[UserName] = CASE memberprinc.[type] 
								WHEN ''S'' THEN memberprinc.[name]
								WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
							 END,
				[UserType] = CASE memberprinc.[type]
								WHEN ''S'' THEN ''SQL User''
								WHEN ''U'' THEN ''Windows User''
							 END, 
				[DatabaseUserName] = memberprinc.[name],   
				[Role] = roleprinc.[name],      
				[PermissionType] = perm.[permission_name],       
				[PermissionState] = perm.[state_desc],       
				[ObjectType] = obj.type_desc,--perm.[class_desc],   
				[ObjectName] = OBJECT_NAME(perm.major_id),
				[ColumnName] = col.[name]
			FROM sys.database_role_members members with (nolock)
			JOIN sys.database_principals roleprinc with (nolock)
				ON roleprinc.[principal_id] = members.[role_principal_id]
			JOIN sys.database_principals memberprinc with (nolock)
				ON memberprinc.[principal_id] = members.[member_principal_id]
			LEFT JOIN sys.login_token ulogin with (nolock)
				on memberprinc.[sid] = ulogin.[sid]
			LEFT JOIN sys.database_permissions perm with (nolock)
				ON perm.[grantee_principal_id] = roleprinc.[principal_id]
			LEFT JOIN sys.columns col with (nolock)
				on col.[object_id] = perm.major_id 
				AND col.[column_id] = perm.[minor_id]
			LEFT JOIN sys.objects obj with (nolock)
				ON perm.[major_id] = obj.[object_id]
			UNION
			--List all access provisioned to the public role, which everyone gets by default
			SELECT  
				[DatabaseName] = ''' + @database +  ''',
				[UserName] = ''{All Users}'',
				[UserType] = ''{All Users}'', 
				[DatabaseUserName] = ''{All Users}'',       
				[Role] = roleprinc.[name],      
				[PermissionType] = perm.[permission_name],       
				[PermissionState] = perm.[state_desc],       
				[ObjectType] = obj.type_desc,
				[ObjectName] = OBJECT_NAME(perm.major_id),
				[ColumnName] = col.[name]
			FROM sys.database_principals roleprinc with (nolock)
			LEFT JOIN sys.database_permissions perm with (nolock)
				ON perm.[grantee_principal_id] = roleprinc.[principal_id]
			LEFT JOIN sys.columns col with (nolock)
				on col.[object_id] = perm.major_id 
				AND col.[column_id] = perm.[minor_id]                   
			JOIN sys.objects obj with (nolock)
				ON obj.[object_id] = perm.[major_id]
			WHERE
				--Only roles
				roleprinc.[type] = ''R'' AND
				--Only public role
				roleprinc.[name] = ''public'' AND
				--Only objects of ours, not the MS objects
				obj.is_ms_shipped = 0
		'

		exec(@sql)

		set @i = @i + 1

	end


	

	/*********************************************************

		get users per group

	**********************************************************/
	drop table if exists #groupNames
	select
		GroupName,
		sort = row_number() over (order by GroupName)
	into #groupNames
	from (
		select distinct
			DatabaseUserName as GroupName
		from #roles
	) x

	drop table if exists #results
	create table #results (
		 account_name sysname
		,type char(8)
		,privilege char(9)
		,mapped_user_name sysname
		,permission_path sysname NULL
	)

	set @i = 1
	declare @groupName varchar(255) 

	while @i <= (select max(sort) from #groupNames)
	begin
		
		set @groupName = (select GroupName from #groupNames where sort = @i) 

		set @SQL =  'INSERT INTO #results EXECUTE xp_logininfo ''' + @groupName + ''', ''members'''

		begin try

			exec (@SQL)

		end try

		begin catch
			print 'didnt work'
		end catch

		set @i = @i + 1

	end

	/*********************************************************

		insert into tables 

	**********************************************************/

	if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'dbo' and TABLE_NAME = 'databaseRoles')
	create table dbo.DatabaseRoles (
		 [DatabaseName]			varchar(255)
		,[UserName]				varchar(255)
		,[UserType]				varchar(255)
		,[DatabaseUserName] 	varchar(255)
		,[Role]   				varchar(255)
		,[PermissionType]		varchar(255)
		,[PermissionState]  	varchar(255)
		,[ObjectType]  			varchar(255)
		,[ObjectName]			varchar(255)
		,[ColumnName] 			varchar(255)
	)

	truncate table dbo.DatabaseRoles

	insert into dbo.DatabaseRoles
	select * from #roles


	if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'dbo' and TABLE_NAME = 'GroupMembers')
	create table dbo.GroupMembers (
		 account_name		sysname
		,type				char(8)
		,privilege			char(9)
		,mapped_user_name	sysname
		,permission_path	sysname
	)

	truncate table dbo.GroupMembers

	insert into dbo.GroupMembers
	select * from #results
	   	 

	


 		

end;





