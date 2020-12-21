DROP SCHEMA IF EXISTS day07 CASCADE;

CREATE SCHEMA IF NOT EXISTS day07;

CREATE UNLOGGED TABLE day07.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day07.inputs (line_value) FROM PROGRAM 'cat ../inputs/day07.txt';
VACUUM ANALYZE day07.inputs;

\timing on

with recursive bags_tree as (
  select nodes.match[1] as parent,
         edges.match[1] as child_count,
         edges.match[2] as child_name
  from day07.inputs i,
  lateral (select regexp_matches(i.line_value, '^(.+) bags contain (.*)$', 'g')) as nodes(match),
  lateral (select regexp_matches(nodes.match[2], '(\d+?) (.+?) bags?', 'g')) as edges(match)
), parents("depth", node) as (
  select 0, 'shiny gold'
  union
  select "depth"+1, new_parents.match
  from parents,
  lateral (select bags_tree.parent from bags_tree where bags_tree.child_name = parents.node) as new_parents(match)
  where parents.depth < 1000
) select concat('Day 07 - Part 1: ', count(distinct node)-1)
  from parents
;
