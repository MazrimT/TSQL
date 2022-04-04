select
     Hostname               = @@SERVERNAME
    ,sessionId              = cast(a.session_id as varchar(100))
    ,blockedBySessionId     = cast(a.blocking_session_id as varchar(100))
    ,startTime              = cast(cast(a.start_time as datetime2(0)) as varchar(100))
    ,cpuTime                = case 
                                when a.cpu_time >= 86400000 
                                    then cast(a.cpu_time / 86400000 as varchar(10)) + 'd ' + cast(CONVERT(varchar, DATEADD(ms, a.cpu_time, 0), 108) as varchar(10))
                                else cast(CONVERT(varchar, DATEADD(ms, a.cpu_time, 0), 108) as varchar(10))
                              end
    ,waitTime               = case 
                                when a.wait_time >= 86400000 
                                    then cast(a.wait_time / 86400000 as varchar(10)) + 'd ' + cast(CONVERT(varchar, DATEADD(ms, a.wait_time, 0), 108) as varchar(10))
                                else cast(CONVERT(varchar, DATEADD(ms, a.wait_time, 0), 108) as varchar(10))
                              end
    ,runTime                = case 
                                when a.total_elapsed_time >= 86400000 
                                    then cast(a.total_elapsed_time / 86400000 as varchar(10)) + 'd ' + cast(CONVERT(varchar, DATEADD(ms, a.total_elapsed_time, 0), 108) as varchar(10))
                                else cast(CONVERT(varchar, DATEADD(ms, a.total_elapsed_time, 0), 108) as varchar(10))
                              end
    ,CPURunTimeRatio        = cast(case when a.total_elapsed_time > 0 then a.cpu_time / cast(a.total_elapsed_time as decimal(32,10)) else 0 end as decimal(18,2))
    ,percentDone            = cast(a.percent_complete as varchar(100))
    ,status                 = a.status
    ,sourceHostname         = s.host_name
    ,username               = isnull(s.login_name, s.nt_user_name)
    ,program                = s.program_name
    ,DB                     = d.name
    ,StoredProc             = object_name(t.objectid, t.dbid)
    ,query                  = substring(t.text, (a.statement_start_offset / 2) + 1, (
                                    (
                                        case a.statement_end_offset when -1 then datalength(t.text)
                                        else a.statement_end_offset
                                        end - a.statement_start_offset
                                    ) / 2
                                    ) + 1
                                )
    ,waitType               = cast(a.wait_type as varchar(100)) 
    ,command                = cast(a.command  as varchar(100)
    ,reads                  = cast(a.reads as varchar(100)) 
    ,writes                 = cast(a.writes as varchar(100))
    ,logicalReads           = cast(a.logical_reads as varchar(100))
    ,parallelism            = cast(a.dop as varchar(100))
    ,RuntimeSec             = a.total_elapsed_time / 1000
from sys.dm_exec_requests a
cross apply sys.dm_exec_sql_text (a.sql_handle) t
left join sys.dm_exec_sessions  s
    on s.session_id = a.session_id
left join sys.databases d
    on d.database_id = isnull(t.dbid, a.database_id)
where s.session_id <> @@SPID
and a.sql_handle is not null
