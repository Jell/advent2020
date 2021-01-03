DROP SCHEMA IF EXISTS day20 CASCADE;

CREATE SCHEMA IF NOT EXISTS day20;

CREATE UNLOGGED TABLE day20.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day20.inputs (line_value) FROM PROGRAM 'cat ../inputs/day20.txt';
VACUUM ANALYZE day20.inputs;

\timing on

create aggregate day20.product(numeric) (
   sfunc = numeric_mul,
   stype = numeric
);

with tile_groups as (
  select coalesce(max(line_number)
                  filter (where line_value = '')
                  over (order by line_number), 0)
         as tile_group,
         line_number,
         line_value
  from day20.inputs
), tile_group_ids as (
  select tile_group, tile_id[1]::bigint as tile_id
  from tile_groups,
  lateral (select regexp_matches(line_value, 'Tile (\d+):')) as match(tile_id)
), tiles as (
  select tile_id,
         line_number - tile_groups.tile_group::bigint - 1 as line_number,
         line_value
  from tile_groups
  join tile_group_ids on tile_group_ids.tile_group = tile_groups.tile_group
  where line_value <> '' and not line_value ~ 'Tile \d+:'
), tile_ids as (
  select distinct tile_id as id from tiles
), tile_edges as (
  select tile_ids.id,
         top.line as top_line,
         reverse(top.line) as top_line_reverse,
         bottom.line as bottom_line,
         reverse(bottom.line) as bottom_line_reverse,
         side.left_line as left_line,
         reverse(side.left_line) as left_line_reverse,
         side.right_line as right_line,
         reverse(side.right_line) as right_line_reverse
  from tile_ids,
  lateral (select line_value
           from tiles
           where tile_ids.id = tiles.tile_id
           order by line_number asc limit 1) as top(line),
  lateral (select line_value
           from tiles
           where tile_ids.id = tiles.tile_id
           order by line_number desc limit 1) as bottom(line),
  lateral (select string_agg(left(line_value, 1), '' order by line_number) as left_line,
                  string_agg(right(line_value, 1), '' order by line_number) as right_line
           from tiles
           where tile_ids.id = tiles.tile_id) as side
), matching_edges as (
  select a.id a_id, b.id b_id
  from tile_edges a
  join tile_edges b on array[
    a.top_line,
    a.top_line_reverse,
    a.bottom_line,
    a.bottom_line_reverse,
    a.left_line,
    a.left_line_reverse,
    a.right_line,
    a.right_line_reverse
  ] && array[
    b.top_line,
    b.top_line_reverse,
    b.bottom_line,
    b.bottom_line_reverse,
    b.left_line,
    b.left_line_reverse,
    b.right_line,
    b.right_line_reverse
  ]
  and a.id <> b.id
), corners as (
  select a_id
  from matching_edges
  group by a_id
  having count(*) = 2
) select concat('Day 20 - Part 1: ', day20.product(a_id))
  from corners
;
