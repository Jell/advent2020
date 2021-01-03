DROP SCHEMA IF EXISTS day20 CASCADE;

CREATE SCHEMA IF NOT EXISTS day20;

CREATE UNLOGGED TABLE day20.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day20.inputs (line_value) FROM PROGRAM 'cat ../inputs/day20.txt';
VACUUM ANALYZE day20.inputs;

\timing on

with recursive tile_groups as (
  select coalesce(max(line_number)
                  filter (where line_value = '')
                  over (order by line_number), 0)
         as tile_group,
         line_number,
         line_value
  from day20.inputs
), tile_group_ids as (
  select tile_group, tile_id[1] as tile_id
  from tile_groups,
  lateral (select regexp_matches(line_value, 'Tile (\d+):')) as match(tile_id)
), original_tiles as (
  select tile_id,
         tile_id as original_tile_id,
         line_number - tile_groups.tile_group::bigint - 1 as line_number,
         line_value
  from tile_groups
  join tile_group_ids on tile_group_ids.tile_group = tile_groups.tile_group
  where line_value <> '' and not line_value ~ 'Tile \d+:'
), rotated_tiles as (
  select concat(tile_id, '-r') as tile_id,
         original_tile_id,
         cell.idx as line_number,
         string_agg(cell.val, '' order by line_number desc) as line_value
  from original_tiles,
  lateral (select * from regexp_split_to_table(line_value, '')
                    with ordinality) as cell(val, idx)
  group by tile_id, original_tile_id, cell.idx
), vertical_flip_tiles as (
  select concat(tile_id, '-v') as tile_id,
         original_tile_id,
         1 + (select max(line_number) from original_tiles) - line_number as line_number,
         line_value
  from (table original_tiles union table rotated_tiles) as tiles
), horizontal_flip_tiles as (
  select concat(tile_id, '-h') as tile_id,
         original_tile_id,
         line_number,
         reverse(line_value) as line_value
  from (table original_tiles union table rotated_tiles union table vertical_flip_tiles) as tiles
), all_possible_tiles as (
  table original_tiles
  union table rotated_tiles
  union table vertical_flip_tiles
  union table horizontal_flip_tiles
), all_possible_tile_ids as (
  select distinct tile_id as id, original_tile_id from all_possible_tiles
), all_possible_tile_edges as (
  select id as tile_id,
         original_tile_id,
         top.line as top_line,
         bottom.line as bottom_line,
         side.left_line as left_line,
         side.right_line as right_line
  from all_possible_tile_ids tile_ids,
  lateral (select line_value
           from all_possible_tiles tiles
           where tile_ids.id = tiles.tile_id
           order by line_number asc limit 1) as top(line),
  lateral (select line_value
           from all_possible_tiles tiles
           where tile_ids.id = tiles.tile_id
           order by line_number desc limit 1) as bottom(line),
  lateral (select string_agg(left(line_value, 1), '' order by line_number) as left_line,
                  string_agg(right(line_value, 1), '' order by line_number) as right_line
           from all_possible_tiles tiles
           where tile_ids.id = tiles.tile_id) as side
), tile_mesh as (
  select tiles.*,
         left_tile.tile_id as left_tile,
         right_tile.tile_id as right_tile,
         top_tile.tile_id as top_tile,
         bottom_tile.tile_id as bottom_tile
  from all_possible_tile_edges tiles
  -- left
  left outer join all_possible_tile_edges left_tile
  on left_tile.right_line = tiles.left_line
  and left_tile.original_tile_id <> tiles.original_tile_id
  -- right
  left outer join all_possible_tile_edges right_tile
  on right_tile.left_line = tiles.right_line
  and right_tile.original_tile_id <> tiles.original_tile_id
  -- top
  left outer join all_possible_tile_edges top_tile
  on top_tile.bottom_line = tiles.top_line
  and top_tile.original_tile_id <> tiles.original_tile_id
  -- bottom
  left outer join all_possible_tile_edges bottom_tile
  on bottom_tile.top_line = tiles.bottom_line
  and bottom_tile.original_tile_id <> tiles.original_tile_id
), top_left_corners as (
  select * from tile_mesh
  where left_tile is null and top_tile is null
), left_column_tiles(map_id, next_tile_id, right_tile, line_number, original_line_number, line_value) as (
  select corner.tile_id,
         corner.bottom_tile,
         corner.right_tile,
         tile.line_number - 1,
         tile.line_number,
         substring(tile.line_value, 2, 8)
  from top_left_corners corner
  join all_possible_tiles tile
  on tile.tile_id = corner.tile_id
  and tile.line_number <> 1
  and tile.line_number <> 10
  union
  (
    with previous_tile as (table left_column_tiles)
    select previous_tile.map_id,
           bottom_tile,
           tile_mesh.right_tile,
           (select max(line_number) from previous_tile) + tile.line_number - 1,
           tile.line_number,
           substring(tile.line_value, 2, 8)
    from previous_tile
    join tile_mesh
    on tile_mesh.tile_id = previous_tile.next_tile_id
    join all_possible_tiles tile
    on tile.tile_id = previous_tile.next_tile_id
    and tile.line_number <> 1
    and tile.line_number <> 10
  )
), full_maps_iterations(map_id, next_tile_id, line_number, original_line_number, line_value) as (
  select map_id,
         right_tile,
         line_number,
         original_line_number,
         line_value
  from left_column_tiles
  union
  (
    with previous_tile as (table full_maps_iterations)
    select previous_tile.map_id,
           tile_mesh.right_tile,
           previous_tile.line_number,
           previous_tile.original_line_number,
           concat(previous_tile.line_value, substring(tile.line_value, 2, 8))
    from previous_tile
    join tile_mesh
    on tile_mesh.tile_id = previous_tile.next_tile_id
    join all_possible_tiles tile
    on tile.tile_id = previous_tile.next_tile_id
    and tile.line_number = previous_tile.original_line_number
  )
), full_maps as (
  select map_id, line_number, line_value
  from full_maps_iterations
  where next_tile_id is null
  order by line_number
), sea_monsters as (
  select *
  from (values ('(#....##....##....###)')) as dragon_body(query),
  lateral (select map_id,
                  line_number,
                  strpos(line_value, (regexp_matches(line_value, dragon_body.query, 'g'))[1])
           from full_maps) as body_match,
  lateral (select true from full_maps
           where full_maps.map_id = body_match.map_id
           and full_maps.line_number = body_match.line_number + 1
           and full_maps.line_value ~ concat('^.{', body_match.strpos-1, '}.#..#..#..#..#..#...')
           ) as feet_check(matching_feet),
  lateral (select true from full_maps
           where full_maps.map_id = body_match.map_id
           and full_maps.line_number = body_match.line_number - 1
           and full_maps.line_value ~ concat('^.{', body_match.strpos-1, '}..................#.')
           ) as head_check(matching_head)
), waves_count as (
  select sum(char_length(replace(line_value, '.',''))) as total
  from full_maps
  where map_id = (select map_id from full_maps limit 1)
), roughness(total) as (
  select (select total from waves_count) - (select count(*) * 15 from sea_monsters)
) select concat('Day 20 - Part 2: ', total)
  from roughness
;
