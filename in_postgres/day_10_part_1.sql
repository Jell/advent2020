DROP SCHEMA IF EXISTS day10 CASCADE;

CREATE SCHEMA IF NOT EXISTS day10;

CREATE UNLOGGED TABLE day10.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value bigint NOT NULL
);

\COPY day10.inputs (line_value) FROM PROGRAM 'cat ../inputs/day10.txt';
VACUUM ANALYZE day10.inputs;

\timing on

with adapters(jolt) as (
  select line_value from day10.inputs
  union
  select 0
  union
  select max(line_value) + 3 from day10.inputs
), jolt_diffs(jolt, diff) as (
  select jolt, jolt - lag(jolt) over (order by jolt)
  from adapters
) select concat(
    'Day 10 - Part 1: ',
    count(*) filter (where diff = 1) *
    count(*) filter (where diff = 3)
  ) from jolt_diffs
;
