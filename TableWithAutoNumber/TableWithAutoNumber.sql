
/*************************************************************************************************************************************
# Instructions:
#   TableId doesn't have to be primary key, but probably should be.
#   TableId has to be any integer type, int, smallint, tinyint, bigint.
#   Replace the "T" with whatever prefix is required.
#   Replace the 0000000 with as many 0's you want to the number to always consist of
#   Replace the (7) with the number of 0's you've picked
#
#   if the "Number" will be used to query big datasets just create an index on it to make database store it.
#
#   technically this can work with none identity "TableId" columns as well.. but then the numbers won't be unique
*************************************************************************************************************************************/

create table dbo.TableTable(
     TableId int identity(1,1) not null
    ,TableNumber as (('T'+left('0000000',(7)-len(convert(varchar(10),TableId))))+convert(varchar(10),TableId))
    ,SomeValue varchar(100) NULL
)

