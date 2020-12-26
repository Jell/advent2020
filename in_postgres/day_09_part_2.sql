DROP SCHEMA IF EXISTS day09 CASCADE;

CREATE SCHEMA IF NOT EXISTS day09;

CREATE UNLOGGED TABLE day09.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value bigint NOT NULL
);

\COPY day09.inputs (line_value) FROM PROGRAM 'cat ../inputs/day09.txt';
VACUUM ANALYZE day09.inputs;

\timing on

with recursive checksums as (
  select i.line_number,
         i.line_value,
         array_agg(ARRAY[previous.number, other_previous.number]) filter (where previous.number + other_previous.number = i.line_value) as matches
  from day09.inputs i,
  lateral (select previous.line_number, previous.line_value
           from day09.inputs previous
           where previous.line_number between (i.line_number - 25) and (i.line_number - 1)) as previous(line_number,number),
  lateral (select other_previous.line_value
           from day09.inputs other_previous
           where other_previous.line_number between i.line_number - 25 and i.line_number - 1
           and other_previous.line_number > previous.line_number) as other_previous(number)
  where i.line_number > 25
  group by i.line_number, i.line_value
), broken(value) as (
  select line_value
  from checksums
  where matches is null
  order by line_number ASC
  limit 1
), potential_hack(l,min,max,acc, target_value) as (
  select 0, 9223372036854775807::bigint, 0::bigint, 0::bigint, (select value from broken)
  union (
    with new_iteration as (
      select l+1 as l,
             potential_hack.min as prev_min,
             potential_hack.max as prev_max,
             potential_hack.acc as prev_acc,
             i.value as new_value,
             target_value
      from potential_hack,
      lateral (select line_value from day09.inputs where line_number = l+1) as i(value)
    )
    select l, new_value, new_value, new_value, target_value
    from new_iteration
    where new_value <= target_value
    union
    select l, least(prev_min, new_value), greatest(prev_max, new_value), prev_acc + new_value, target_value
    from new_iteration
    where prev_acc + new_value <= target_value
  )
) select concat('Day 09 - Part 2: ', potential_hack.min + potential_hack.max)
  from potential_hack
  where acc = target_value
  limit 1
;
