select
     Hostname           = @@SERVERNAME
    ,JobId              = ja.job_id
    ,JobName            = j.name
    ,StartTime          = cast(ja.start_execution_date as datetime2(0))
    ,RunTime            = case 
                            when rt.runtimeMS >= 86400000 
                                then cast(rt.runtimeMS / 86400000 as varchar(10)) + 'd ' + cast(CONVERT(varchar, DATEADD(ms, rt.runtimeMS, 0), 108) as varchar(10))
                            else cast(CONVERT(varchar, DATEADD(ms, rt.runtimeMS, 0), 108) as varchar(10))
                          end
    ,CurrentStepId      = case
                            when js1.on_success_step_id > 0 
                                then js2.step_id
                            when js1.on_success_step_id = 0 
                                then js3.step_id
                          end
    ,CurrentStepName    = case
                            when js1.on_success_step_id > 0 
                                then js2.step_name
                            when js1.on_success_step_id = 0 
                                then js3.step_name
                          end
    ,RunTimeSec         = datediff(second, ja.start_execution_date, getdate())
from msdb.dbo.sysjobactivity ja 
left join msdb.dbo.sysjobhistory jh 
    on ja.job_history_id = jh.instance_id
join msdb.dbo.sysjobs j
    on ja.job_id = j.job_id
join msdb.dbo.sysjobsteps js1
    on js1.job_id = ja.job_id
    and js1.step_id = ja.last_executed_step_id
left join msdb.dbo.sysjobsteps js2
    on js2.job_id = ja.job_id
    and js2.step_id = isnull(ja.last_executed_step_id,0)+1
left join msdb.dbo.sysjobsteps js3
    on js3.job_id = ja.job_id
    and js3.step_Id = js1.on_success_step_id
cross apply (
    select 
        runtimeMS = datediff(ms, ja.start_execution_date, getdate())
) as rt
where ja.session_id = (
    select top 1 
        ss.session_id 
    from msdb.dbo.syssessions ss 
    order by ss.agent_start_date desc
)
and ja.start_execution_date is not null
and ja.stop_execution_date is null
