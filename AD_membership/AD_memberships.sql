/* create table if it doesn't exist
create table dbo.memberships (
    userObjectGUID varchar(255),
    groupObjectGUID varchar(255),
    hierarchy int,
    _inserted datetime2(0),
    _updated datetime2(0),
    _deleted datetime2(0)
)
*/


drop table if exists #userGroup;
with cte as (
    select 
        objectGUID,
        memberOf =  replace(
                    replace(
                    replace(
                    replace(
                    memberOf, 
                    '(', '['), 
                    ',)', ']'),
                    ')', ']'),
                    '''', '"')
    from dbo.users u
    where u.memberOf <> 'None'
)
select
     userObjectGUID        = t.objectGUID
    ,groupObjectGUID    = g.objectGUID
into #userGroup
from cte t
cross apply OPENJSON(memberOf) as mo
left join dbo.groups g
    on g.distinguishedName = mo.value
;

/* group that are members of groups */

drop table if exists #groupGroup;
with cte as (
    select
        g.objectGUID,
        memberOf =    replace(
                    replace(
                    replace(
                    replace(
                    memberOf, 
                    '(', '['), 
                    ',)', ']'),
                    ')', ']'),
                    '''', '"')
    from dbo.groups g
    where memberOf <> 'None'
)
select
        groupObjectGUID        = t.objectGUID
    ,memberOfObjectGUID        = g.objectGUID
into #groupGroup
from cte t
cross apply OPENJSON(memberOf) as mo
left join dbo.groups g
    on g.distinguishedName = mo.value
;


/* join everything together where the next level is not already exists previously in the hierarchy, can probably be done with a loop.. but just doing 15 levels */
/* todo improve to be recrusive and dynamic, this was written in short time and I don't have access to this data anymore to improve it */
drop table if exists #grouphierarchy
select
     userObjectGUID             = u.userObjectGUID
    ,memberOfObjectGUID0        = u.groupObjectGUID
    ,memberOfObjectGUID1        = g1.memberOfObjectGUID
    ,memberOfObjectGUID2        = g2.memberOfObjectGUID
    ,memberOfObjectGUID3        = g3.memberOfObjectGUID
    ,memberOfObjectGUID4        = g4.memberOfObjectGUID
    ,memberOfObjectGUID5        = g5.memberOfObjectGUID
    ,memberOfObjectGUID6        = g6.memberOfObjectGUID
    ,memberOfObjectGUID7        = g7.memberOfObjectGUID
    ,memberOfObjectGUID8        = g8.memberOfObjectGUID
    ,memberOfObjectGUID9        = g9.memberOfObjectGUID
    ,memberOfObjectGUID10       = g10.memberOfObjectGUID
    ,memberOfObjectGUID11       = g11.memberOfObjectGUID
    ,memberOfObjectGUID12       = g12.memberOfObjectGUID
    ,memberOfObjectGUID13       = g13.memberOfObjectGUID
    ,memberOfObjectGUID14       = g14.memberOfObjectGUID
    ,memberOfObjectGUID15       = g15.memberOfObjectGUID
into #grouphierarchy
from #userGroup u
left join #groupGroup g1
    on g1.groupObjectGUID = u.groupObjectGUID
left join #groupGroup g2
    on g2.groupObjectGUID = g1.memberOfObjectGUID
    and g2.groupObjectGUID <> g1.groupObjectGUID
left join #groupGroup g3
    on g3.groupObjectGUID = g2.memberOfObjectGUID
    and g3.groupObjectGUID <> g1.groupObjectGUID
    and g3.groupObjectGUID <> g2.groupObjectGUID
left join #groupGroup g4
    on g4.groupObjectGUID = g3.memberOfObjectGUID
    and g4.groupObjectGUID <> g1.groupObjectGUID
    and g4.groupObjectGUID <> g2.groupObjectGUID
    and g4.groupObjectGUID <> g3.groupObjectGUID
left join #groupGroup g5
    on g5.groupObjectGUID = g4.memberOfObjectGUID
    and g5.groupObjectGUID <> g1.groupObjectGUID
    and g5.groupObjectGUID <> g2.groupObjectGUID
    and g5.groupObjectGUID <> g3.groupObjectGUID
    and g5.groupObjectGUID <> g4.groupObjectGUID
left join #groupGroup g6
    on g6.groupObjectGUID = g5.memberOfObjectGUID
    and g6.groupObjectGUID <> g1.groupObjectGUID
    and g6.groupObjectGUID <> g2.groupObjectGUID
    and g6.groupObjectGUID <> g3.groupObjectGUID
    and g6.groupObjectGUID <> g4.groupObjectGUID
    and g6.groupObjectGUID <> g5.groupObjectGUID
left join #groupGroup g7
    on g7.groupObjectGUID = g6.memberOfObjectGUID
    and g7.groupObjectGUID <> g1.groupObjectGUID
    and g7.groupObjectGUID <> g2.groupObjectGUID
    and g7.groupObjectGUID <> g3.groupObjectGUID
    and g7.groupObjectGUID <> g4.groupObjectGUID
    and g7.groupObjectGUID <> g5.groupObjectGUID
    and g7.groupObjectGUID <> g6.groupObjectGUID
left join #groupGroup g8
    on g8.groupObjectGUID = g7.memberOfObjectGUID
    and g8.groupObjectGUID <> g1.groupObjectGUID
    and g8.groupObjectGUID <> g2.groupObjectGUID
    and g8.groupObjectGUID <> g3.groupObjectGUID
    and g8.groupObjectGUID <> g4.groupObjectGUID
    and g8.groupObjectGUID <> g5.groupObjectGUID
    and g8.groupObjectGUID <> g6.groupObjectGUID
    and g8.groupObjectGUID <> g7.groupObjectGUID
left join #groupGroup g9
    on g9.groupObjectGUID = g8.memberOfObjectGUID
    and g9.groupObjectGUID <> g1.groupObjectGUID
    and g9.groupObjectGUID <> g2.groupObjectGUID
    and g9.groupObjectGUID <> g3.groupObjectGUID
    and g9.groupObjectGUID <> g4.groupObjectGUID
    and g9.groupObjectGUID <> g5.groupObjectGUID
    and g9.groupObjectGUID <> g6.groupObjectGUID
    and g9.groupObjectGUID <> g7.groupObjectGUID
    and g9.groupObjectGUID <> g8.groupObjectGUID
left join #groupGroup g10
    on g10.groupObjectGUID = g9.memberOfObjectGUID    
    and g10.groupObjectGUID <> g1.groupObjectGUID
    and g10.groupObjectGUID <> g2.groupObjectGUID
    and g10.groupObjectGUID <> g3.groupObjectGUID
    and g10.groupObjectGUID <> g4.groupObjectGUID
    and g10.groupObjectGUID <> g5.groupObjectGUID
    and g10.groupObjectGUID <> g6.groupObjectGUID
    and g10.groupObjectGUID <> g7.groupObjectGUID
    and g10.groupObjectGUID <> g8.groupObjectGUID
    and g10.groupObjectGUID <> g9.groupObjectGUID
left join #groupGroup g11
    on g11.groupObjectGUID = g10.memberOfObjectGUID    
    and g11.groupObjectGUID <> g1.groupObjectGUID
    and g11.groupObjectGUID <> g2.groupObjectGUID
    and g11.groupObjectGUID <> g3.groupObjectGUID
    and g11.groupObjectGUID <> g4.groupObjectGUID
    and g11.groupObjectGUID <> g5.groupObjectGUID
    and g11.groupObjectGUID <> g6.groupObjectGUID
    and g11.groupObjectGUID <> g7.groupObjectGUID
    and g11.groupObjectGUID <> g8.groupObjectGUID
    and g11.groupObjectGUID <> g9.groupObjectGUID
    and g11.groupObjectGUID <> g10.groupObjectGUID
left join #groupGroup g12
    on g12.groupObjectGUID = g11.memberOfObjectGUID    
    and g12.groupObjectGUID <> g1.groupObjectGUID
    and g12.groupObjectGUID <> g2.groupObjectGUID
    and g12.groupObjectGUID <> g3.groupObjectGUID
    and g12.groupObjectGUID <> g4.groupObjectGUID
    and g12.groupObjectGUID <> g5.groupObjectGUID
    and g12.groupObjectGUID <> g6.groupObjectGUID
    and g12.groupObjectGUID <> g7.groupObjectGUID
    and g12.groupObjectGUID <> g8.groupObjectGUID
    and g12.groupObjectGUID <> g9.groupObjectGUID
    and g12.groupObjectGUID <> g10.groupObjectGUID
    and g12.groupObjectGUID <> g11.groupObjectGUID
left join #groupGroup g13
    on g13.groupObjectGUID = g12.memberOfObjectGUID    
    and g13.groupObjectGUID <> g1.groupObjectGUID
    and g13.groupObjectGUID <> g2.groupObjectGUID
    and g13.groupObjectGUID <> g3.groupObjectGUID
    and g13.groupObjectGUID <> g4.groupObjectGUID
    and g13.groupObjectGUID <> g5.groupObjectGUID
    and g13.groupObjectGUID <> g6.groupObjectGUID
    and g13.groupObjectGUID <> g7.groupObjectGUID
    and g13.groupObjectGUID <> g8.groupObjectGUID
    and g13.groupObjectGUID <> g9.groupObjectGUID
    and g13.groupObjectGUID <> g10.groupObjectGUID
    and g13.groupObjectGUID <> g11.groupObjectGUID
    and g13.groupObjectGUID <> g12.groupObjectGUID
left join #groupGroup g14
    on g14.groupObjectGUID = g12.memberOfObjectGUID    
    and g14.groupObjectGUID <> g1.groupObjectGUID
    and g14.groupObjectGUID <> g2.groupObjectGUID
    and g14.groupObjectGUID <> g3.groupObjectGUID
    and g14.groupObjectGUID <> g4.groupObjectGUID
    and g14.groupObjectGUID <> g5.groupObjectGUID
    and g14.groupObjectGUID <> g6.groupObjectGUID
    and g14.groupObjectGUID <> g7.groupObjectGUID
    and g14.groupObjectGUID <> g8.groupObjectGUID
    and g14.groupObjectGUID <> g9.groupObjectGUID
    and g14.groupObjectGUID <> g10.groupObjectGUID
    and g14.groupObjectGUID <> g11.groupObjectGUID
    and g14.groupObjectGUID <> g12.groupObjectGUID
    and g14.groupObjectGUID <> g13.groupObjectGUID
left join #groupGroup g15
    on g15.groupObjectGUID = g12.memberOfObjectGUID    
    and g15.groupObjectGUID <> g1.groupObjectGUID
    and g15.groupObjectGUID <> g2.groupObjectGUID
    and g15.groupObjectGUID <> g3.groupObjectGUID
    and g15.groupObjectGUID <> g4.groupObjectGUID
    and g15.groupObjectGUID <> g5.groupObjectGUID
    and g15.groupObjectGUID <> g6.groupObjectGUID
    and g15.groupObjectGUID <> g7.groupObjectGUID
    and g15.groupObjectGUID <> g8.groupObjectGUID
    and g15.groupObjectGUID <> g9.groupObjectGUID
    and g15.groupObjectGUID <> g10.groupObjectGUID
    and g15.groupObjectGUID <> g11.groupObjectGUID
    and g15.groupObjectGUID <> g12.groupObjectGUID
    and g15.groupObjectGUID <> g13.groupObjectGUID
    and g15.groupObjectGUID <> g14.groupObjectGUID
;

/* add it together to a single table with level */
drop table if exists #temp
create table #temp (
    userObjectGUID    varchar(255),
    groupObjectGUID varchar(255),
    hierarchy        int
)


declare @i int = 0;   /* starting at 0 as the group that a user is direct member of */
declare @nr varchar(10);
declare @sql nvarchar(max);

while @i <= 15
begin

    set @nr = cast(@i as varchar(10));
    set @sql = 'insert into #temp 
                select
                        userObjectGUID
                    ,memberOfObjectGUID' + @nr + '
                    ,hierarchy = ' + @nr + '
                from #grouphierarchy t
                where t.memberOfObjectGUID' + @nr + ' is not null';
    exec(@sql);

    set @i += 1;
end
;



/********************************************************************************

    merge with memberships table

*********************************************************************************/

with cte as (
    select 
         userObjectGUID
        ,groupObjectGUID
        ,hierarchy = min(t.hierarchy)
    from #temp t
    group by 
         userObjectGUID
        ,groupObjectGUID
)
merge dbo.memberships t
using cte s
    on s.userObjectGUID = t.userObjectGUID
    and s.groupObjectGUID = t.groupObjectGUID
when matched and (
    s.hierarchy <> t.hierarchy 
    or t._deleted is not null
) then update 
set
     t.hierarchy = s.hierarchy
    ,t._updated = getdate()
    ,t._deleted = null
when not matched by target then 
insert (
     userobjectGUID
    ,groupObjectGUID
    ,hierarchy
    ,_inserted
    ,_updated
)
values (
     s.userobjectGUID
    ,s.groupObjectGUID
    ,s.hierarchy
    ,getdate()
    ,getdate()
)
when not matched by source and t._deleted is null then update
set
    t._deleted = getdate()
