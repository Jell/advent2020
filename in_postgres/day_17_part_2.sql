DROP SCHEMA IF EXISTS day17 CASCADE;

CREATE SCHEMA IF NOT EXISTS day17;

CREATE UNLOGGED TABLE day17.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day17.inputs (line_value) FROM PROGRAM 'cat ../inputs/day17.txt';
VACUUM ANALYZE day17.inputs;

\timing on

with recursive starting_cubes as (
  select cube.x::int, cube.y::int, 1, 1
  from day17.inputs i,
  lateral (select row_number() over (), i.line_number, * from regexp_split_to_table(i.line_value, '')) as cube(x,y,v)
  where cube.v = '#'
), offsets(x,y,z,w) as (
  select x_offset.value, y_offset.value, z_offset.value, w_offset.value
  from       (values (-1), (0), (1)) as x_offset(value)
  cross join (values (-1), (0), (1)) as y_offset(value)
  cross join (values (-1), (0), (1)) as z_offset(value)
  cross join (values (-1), (0), (1)) as w_offset(value)
), system(gen, x, y, z, w) as (
  select 0, * from starting_cubes
  union (
  -- trick: can only reference to system once, so use another with to cache it
  with prev_gen as (select * from system)
  select gen + 1, next_gen.x, next_gen.y, next_gen.z, next_gen.w
  from prev_gen
  cross join offsets,
  lateral (select prev_gen.x + offsets.x,
                  prev_gen.y + offsets.y,
                  prev_gen.z + offsets.z,
                  prev_gen.w + offsets.w) as next_gen(x,y,z,w),
  lateral (select prev_gen.x = next_gen.x
              and prev_gen.y = next_gen.y
              and prev_gen.z = next_gen.z
              and prev_gen.w = next_gen.w) as active(yes)
  where (select count(*)
         from offsets
         where exists (select 1 from prev_gen
                       where prev_gen.x = next_gen.x + offsets.x
                       and   prev_gen.y = next_gen.y + offsets.y
                       and   prev_gen.z = next_gen.z + offsets.z
                       and   prev_gen.w = next_gen.w + offsets.w)
         and (offsets.x, offsets.y, offsets.z, offsets.w) != (0,0,0,0)
         ) between (case when active.yes then 2 else 3 end) and 3
  and gen < 6)
) select concat('Day 17 - Part 2: ', count(*))
  from system
  where gen = 6
;
