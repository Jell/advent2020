DROP SCHEMA IF EXISTS day16 CASCADE;

CREATE SCHEMA IF NOT EXISTS day16;

CREATE UNLOGGED TABLE day16.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day16.inputs (line_value) FROM PROGRAM 'cat ../inputs/day16.txt';
VACUUM ANALYZE day16.inputs;

\timing on

with parts as (
  select line_number,
         line_value as string,
         count(*) filter (where line_value = '') over (order by line_number) as part
  from day16.inputs
  where line_value != 'your ticket:'
  and line_value != 'nearby tickets:'
), rules as (
  select
    rule.regexp_matches[1] as field,
    rule.regexp_matches[2]::int as range1_min,
    rule.regexp_matches[3]::int as range1_max,
    rule.regexp_matches[4]::int as range2_min,
    rule.regexp_matches[5]::int as range2_max
  from parts,
  lateral (select regexp_matches(string, '^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)$')) as rule
  where part = 0
  and string != ''
), nearby_tickets as (
  select line_number as ticket_id,
         field.value::int as field_value
  from parts,
  lateral (select regexp_split_to_table(string, ',')) as field(value)
  where part = 2
  and string != ''
), invalid_fields as (
  select *
  from nearby_tickets
  where not exists (
    select 1
    from rules
    where nearby_tickets.field_value between rules.range1_min and rules.range1_max
    or    nearby_tickets.field_value between rules.range2_min and rules.range2_max
  )
) select concat('Day 16 - Part 1: ', sum(field_value))
  from invalid_fields
;
