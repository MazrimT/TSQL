USE [DatabaseName]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[urlToBaseUrl]  (@strURL varchar(1000))
RETURNS varchar(1000)
AS
BEGIN

    /* removing start of url if exists "http://" and so on */
    if left(@strUrl, 10) like '%://%'
        set @strURL = substring(@strUrl, charindex('://', @strUrl)+3, len(@strUrl))

    /* Remove everything after "/" exists since this will never be part of url */
    if charindex('/', @strURL) > 0 
        set @strURL = left(@strURL, charindex('/', @strURL)-1)

    /* Remove everything after ":" exists since it means there's a port in the url*/
    if charindex(':', @strURL) > 0 
        set @strURL = left(@strURL, charindex(':', @strURL)-1)

    return @strURL
END
