USE [DatabaseName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[urlToDomain]  (@strURL varchar(1000))
RETURNS varchar(1000)
AS
BEGIN

    declare @pos1 varchar(100)
    declare @pos2 varchar(100)
    declare @pos3 varchar(100)

    /* removing start of url if exists "http://" and so on */
    if left(@strUrl, 10) like '%://%'
        set @strURL = substring(@strUrl, charindex('://', @strUrl)+3, len(@strUrl))
    
    /* Remove everything after "/" exists since this will never be part of url */
    if charindex('/', @strURL) > 0 
        set @strURL = left(@strURL, charindex('/', @strURL)-1)

    /* Remove everything after ":" exists since it means there's a port in the url*/
    if charindex(':', @strURL) > 0 
        set @strURL = left(@strURL, charindex(':', @strURL)-1)


    /* remove all but the last 3 parts if it's longer since domain is always max 3*/
    if len(@strURL) - len(replace(@strUrl, '.', '')) = 2
    begin
        set @pos1 = reverse(left(reverse(@strUrl), charindex('.', reverse(@strUrl))-1))
        set @pos2 = reverse(left(substring(reverse(@strUrl), len(@pos1)+2, len(@strUrl)), charindex('.', substring(reverse(@strUrl), len(@pos1)+2, len(@strUrl)))-1))

        
        if @pos2 not in ('com', 'net', 'org', 'edu', 'gov', 'asn', 'id', 'csiro', 'co', 'ac', 'gv', 'or', 'priv', 'games', 'gov', 'info', 'biz', 'pro', 'int','in')
            set @strUrl = @pos2 + '.' + @pos1

    end
    if len(@strURL) - len(replace(@strUrl, '.', '')) >= 3
    begin
        set @pos1 = reverse(left(reverse(@strUrl), charindex('.', reverse(@strUrl))-1))
        set @pos2 = reverse(left(substring(reverse(@strUrl), len(@pos1)+2, len(@strUrl)), charindex('.', substring(reverse(@strUrl), len(@pos1)+2, len(@strUrl)))-1))
        set @pos3 = reverse(left(substring(reverse(@strUrl), len(@pos1)+len(@pos2)+3, len(@strUrl)), charindex('.', substring(reverse(@strUrl), len(@pos1)+len(@pos2)+3, len(@strUrl)))-1))
        set @strURL =  @pos2 + '.' + @pos1
        /* these are the values that are known to be in 2-part top domains like "co.uk" (also known as 2nd level top domain). if the middle of 3 is one of these it's art of the top domain.*/ 
        if @pos2 in ('com', 'net', 'org', 'edu', 'gov', 'asn', 'id', 'csiro', 'co', 'ac', 'gv', 'or', 'priv', 'games', 'gov', 'info', 'biz', 'pro', 'int','in')
            set @strUrl = @pos3 + '.' + @pos2 + '.' + @pos1

    end


    /* if it's an Ip address do "unknown" */
    if isnumeric(replace(@strURL,'.','')) = 1
        set @strURL = 'IpAddress'





    return @strURL
END

