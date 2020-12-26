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
), potential_hack(l,min,max,acc) as (
  select 0, 9223372036854775807::bigint, 0::bigint, 0::bigint
  union
  (with prev_gen as (select * from potential_hack)
  select l+1, i.value, i.value, i.value
  from prev_gen,
  lateral (select line_value from day09.inputs where line_number = l+1) as i(value)
  where i.value <= (select value from broken)
  union
  select l+1, least(i.value, prev_gen.min), greatest(i.value, prev_gen.max), prev_gen.acc + i.value
  from prev_gen,
  lateral (select line_value from day09.inputs where line_number = l+1) as i(value)
  where prev_gen.acc + i.value <= (select value from broken)
  )
) select concat('Day 09 - Part 2: ', potential_hack.min + potential_hack.max)
  from potential_hack
  where acc = (select value from broken)
  limit 1
;
