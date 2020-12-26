DROP SCHEMA IF EXISTS day09 CASCADE;

CREATE SCHEMA IF NOT EXISTS day09;

CREATE UNLOGGED TABLE day09.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value bigint NOT NULL
);

\COPY day09.inputs (line_value) FROM PROGRAM 'cat ../inputs/day09.txt';
VACUUM ANALYZE day09.inputs;

\timing on

with checksums as (
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
) select concat('Day 09 - Part 1: ', line_value)
  from checksums
  where matches is null
  order by line_number ASC
  limit 1
;
