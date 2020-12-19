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
), answer_counts as (
  select group_id, count(distinct question) as questions
  from answers
  where answers.question != ''
  group by group_id
) select concat('Day 06 - Part 1: ', sum(questions))
  from answer_counts
;
