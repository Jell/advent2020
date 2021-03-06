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
  select cube.x::int, cube.y::int, 1
  from day17.inputs i,
  lateral (select row_number() over (), i.line_number, * from regexp_split_to_table(i.line_value, '')) as cube(x,y,v)
  where cube.v = '#'
), offsets(x,y,z) as (
  select x_offset.value, y_offset.value, z_offset.value
  from       (values (-1), (0), (1)) as x_offset(value)
  cross join (values (-1), (0), (1)) as y_offset(value)
  cross join (values (-1), (0), (1)) as z_offset(value)
), system(gen, x, y, z) as (
  select 0, * from starting_cubes
  union (
    -- trick: can only reference to system once, so use another with to cache it
    with prev_gen as (select * from system)
    select gen + 1, next_gen.x, next_gen.y, next_gen.z
    from prev_gen
    cross join offsets,
    lateral (select prev_gen.x + offsets.x,
                    prev_gen.y + offsets.y,
                    prev_gen.z + offsets.z) as next_gen(x,y,z),
    lateral (select prev_gen.x = next_gen.x
                and prev_gen.y = next_gen.y
                and prev_gen.z = next_gen.z) as active(yes),
    lateral (select count(*) from offsets
             where exists (select 1 from prev_gen
                           where prev_gen.x = next_gen.x + offsets.x
                           and   prev_gen.y = next_gen.y + offsets.y
                           and   prev_gen.z = next_gen.z + offsets.z)
             and (offsets.x, offsets.y, offsets.z) != (0,0,0)) as alive_neighbors(count)
    where gen < 6
    and case
        when active.yes then alive_neighbors.count between 2 and 3
        else alive_neighbors.count = 3
        end
  )
) select concat('Day 17 - Part 1: ', count(*))
  from system
  where gen = 6
;
