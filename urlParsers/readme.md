# URL Parsers

## urlToBaseUrl
parses any correctly formated url and returns the url without prefix, ports and stuff after / (also works on "2nd level domains" such as "something.co.uk")

usage:  
exec dbo.urlToBaseUrl 'someUrl.com'  
or
select 
  BaseUrl = dbo.urlToBaseUrl(url) 
from dbo.TablesThatHasUrlColumn

Example:  
htps://subdomain.domain.com:443/somesite/subsite/somepage.html -> subdomain.domain.com

## urlToDomain
parses any correctly formated url and returns the domain. (also works on "2nd level domains" such as "something.co.uk")  
  
usage:  
exec dbo.urlToDomain 'someUrl.com'  
or
select 
  Domain = dbo.urlToDomain(url) 
from dbo.TablesThatHasUrlColumn
  
Examples:  
https://subdomain.domain.com:443/somesite/subsite/somepage.html -> domain.com  
https://subdomain.domain.co.uk:443/somesite/subsite/somepage.html -> domain.co.uk  

## urlToTopDomain
parses any correctly formated url and returns the top-domain. (also works on "2nd level domains" such as "something.co.uk")  
  
usage:  
exec dbo.urlToTopDomain 'someUrl.com'  
or
select 
  TopDomain = dbo.urlToTopDomain(url) 
from dbo.TablesThatHasUrlColumn

Examples:  
https://subdomain.domain.com:443/somesite/subsite/somepage.html -> com  
https://subdomain.domain.co.uk:443/somesite/subsite/somepage.html -> co.uk