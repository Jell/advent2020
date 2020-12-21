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
         edges.match[1]::int as child_count,
         edges.match[2] as child_name
  from day07.inputs i,
  lateral (select regexp_matches(i.line_value, '^(.+) bags contain (.*)$', 'g')) as nodes(match),
  lateral (select regexp_matches(nodes.match[2], '(\d+?) (.+?) bags?', 'g')) as edges(match)
), children("depth", parent, "count", "product", node) as (
  select 0, null, 1, 1, 'shiny gold'
  union
  select "depth"+1, children.node, new_children.child_count, children.product * new_children.child_count, new_children.child_name
  from children,
  lateral (select * from bags_tree where bags_tree.parent = children.node) as new_children
  where children.depth < 1000
) select concat('Day 07 - Part 2: ', sum(children.product) - 1)
  from children
;
