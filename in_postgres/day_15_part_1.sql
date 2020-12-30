DROP SCHEMA IF EXISTS day15 CASCADE;

CREATE SCHEMA IF NOT EXISTS day15;

CREATE UNLOGGED TABLE day15.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day15.inputs (line_value) FROM PROGRAM 'cat ../inputs/day15.txt';
VACUUM ANALYZE day15.inputs;

\timing on

create extension if not exists hstore;

with recursive inputs as (
  select ordinality i, n::bigint
  from day15.inputs,
  lateral regexp_split_to_table(line_value, ',') with ordinality as n
), game(i, n, mem) as (
  (select i, n, (select hstore(array_agg(n::text), array_agg(i::text)) from inputs)
   from inputs
   order by i desc
   limit 1)
  union
  select game.i+1,
         game.i - (coalesce(mem->(game.n::text), game.i::text))::bigint,
         mem || hstore(array[game.n::text, game.i::text])
  from game
) select concat('Day 15 - Part 1: ', n)
  from game where i = 2020 limit 1
;
