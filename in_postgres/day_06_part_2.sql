DROP SCHEMA IF EXISTS day06 CASCADE;

CREATE SCHEMA IF NOT EXISTS day06;

CREATE UNLOGGED TABLE day06.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day06.inputs (line_value) FROM PROGRAM 'cat ../inputs/day06.txt';
VACUUM ANALYZE day06.inputs;

\timing on

with answers as (
  select
    line_number as passenger_id,
    answers.question as question,
    coalesce(max(line_number) filter (where line_value = '') over (order by line_number)) as group_id
  from day06.inputs,
  lateral (select regexp_split_to_table(line_value, '')) as answers(question)
), all_yes as (
  select group_id, potential.question
  from answers
  cross join lateral (select distinct a.question from answers a where question != '') as potential(question)
  where answers.question != ''
  group by group_id, potential.question
  having count(*) filter (where answers.question = potential.question) = count(distinct passenger_id)
) select concat('Day 06 - Part 2: ', count(*))
  from all_yes
;
