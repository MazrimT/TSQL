USE [DatabaseName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[urlToTopDomain]  (@strURL varchar(1000))
RETURNS varchar(1000)
AS
BEGIN

    declare @pos1 varchar(100)
    declare @pos2 varchar(100)

    /* removing start of url if exists "http://" and so on */
    if left(@strUrl, 10) like '%://%'
        set @strURL = substring(@strUrl, charindex('://', @strUrl)+3, len(@strUrl))
    
    /* Remove everything after "/" exists since this will never be part of url */
    if charindex('/', @strURL) > 0 
        set @strURL = left(@strURL, charindex('/', @strURL)-1)

    /* Remove everything after ":" exists since it means there's a port in the url*/
    if charindex(':', @strURL) > 0 
        set @strURL = left(@strURL, charindex(':', @strURL)-1)


    /* if only one dot in left in the url */
    if len(@strURL) - len(replace(@strUrl, '.', '')) = 1
        set @strURL = substring(@strUrl, charindex('.', @strURL)+1, len(@strUrl))

    /* if two or more dots left in the url */
    if len(@strURL) - len(replace(@strUrl, '.', '')) >= 2
    begin
        set @pos1 = reverse(left(reverse(@strUrl), charindex('.', reverse(@strUrl))-1))
        set @pos2 = reverse(left(substring(reverse(@strUrl), len(@pos1)+2, len(@strUrl)), charindex('.', substring(reverse(@strUrl), len(@pos1)+2, len(@strUrl)))-1))
    
        set @strUrl = @pos1

        /* these are the values that are known to be in 2-part top domains like "co.uk" (also known as 2nd level top domain). if the middle of 3 is one of these it's art of the top domain.*/ 
        if @pos2 in ('com', 'net', 'org', 'edu', 'gov', 'asn', 'id', 'csiro', 'co', 'ac', 'gv', 'or', 'priv', 'games', 'gov', 'info', 'biz', 'pro', 'int','in')
            set @strUrl = @pos2 + '.' + @pos1

    end


    /* if it's an Ip address do "unknown" */
    if isnumeric(replace(@strURL,'.','')) = 1
        set @strURL = 'Unknown'
    
    return @strURL

END

