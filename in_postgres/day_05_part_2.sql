DROP SCHEMA IF EXISTS day05 CASCADE;

CREATE SCHEMA IF NOT EXISTS day05;

CREATE UNLOGGED TABLE day05.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day05.inputs (line_value) FROM PROGRAM 'cat ../inputs/day05.txt';
VACUUM ANALYZE day05.inputs;

\timing on

with boarding_passes as (
  select line_number, line_value as boarding_pass, seat.*, seat.row * 8 + seat.column as seat_id
  from day05.inputs,
  lateral (select
    translate(substring(line_value from 1 for 7), 'FB', '01')::bit(7)::integer as "row",
    translate(substring(line_value from 8 for 3), 'LR', '01')::bit(3)::integer as "column"
  ) as seat
) select concat('Day 05 - Part 2: ', potential.id)
  from (select min(seat_id), max(seat_id) from boarding_passes) as boarding_stats,
  lateral (select generate_series(boarding_stats.min, boarding_stats.max)) as potential(id)
  where not exists (select 1 from boarding_passes where boarding_passes.seat_id = potential.id)
  and exists (select 1 from boarding_passes where boarding_passes.seat_id = potential.id + 1)
  and exists (select 1 from boarding_passes where boarding_passes.seat_id = potential.id - 1)
;
