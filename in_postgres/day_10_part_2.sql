DROP SCHEMA IF EXISTS day10 CASCADE;

CREATE SCHEMA IF NOT EXISTS day10;

CREATE UNLOGGED TABLE day10.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value bigint NOT NULL
);

\COPY day10.inputs (line_value) FROM PROGRAM 'cat ../inputs/day10.txt';
VACUUM ANALYZE day10.inputs;

\timing on

with recursive adapters(jolt) as (
  select line_value from day10.inputs
  union
  select 0
  union
  select max(line_value) + 3 from day10.inputs
), combos(gen, node, total) as (
  select 0::bigint, 0::bigint, 1::numeric
  union (
    with current_state as (table combos)
    select gen+1, node, total from current_state
    union
    select (select max(gen) from current_state)+1, jolt, link_count
    from (select *
          from adapters
          where jolt > (select max(node) from current_state)
          order by jolt asc limit 1) as next_adapter,
    lateral (select (select sum(total)
                     from adapters
                     join current_state on current_state.node = adapters.jolt
                     where adapters.jolt between next_adapter.jolt - 3
                                             and next_adapter.jolt - 1))
            as total(link_count)
  )
) select concat('Day 10 - Part 2: ', total)
  from combos
  where node = (select max(jolt) from adapters)
  limit 1
;
