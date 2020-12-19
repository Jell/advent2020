DROP SCHEMA IF EXISTS day04 CASCADE;

CREATE SCHEMA IF NOT EXISTS day04;

CREATE UNLOGGED TABLE day04.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day04.inputs (line_value) FROM PROGRAM 'cat ../inputs/day04.txt';
VACUUM ANALYZE day04.inputs;

\timing on

with recursive passport_lines(pass_id, i, line) as (
   select 0, 0, ''
   union
   select case when line_value = '' then pass_id+1 else pass_id end, i+1, line_value
   from passport_lines,
        lateral (select * from day04.inputs where line_number = i + 1) as inputs
), passports as (
  select pass_id, jsonb_object_agg(tags.key, tags.value) as fields
  from passport_lines,
  lateral (select regexp_split_to_table(line, ' ')) as label(val),
  lateral (select split_part(label.val, ':', 1) as "key", split_part(label.val, ':', 2) as value) as tags
  where line <> ''
  group by pass_id
) select concat('Day 04 - Part 1: ', count(*))
  from passports
  where fields ? 'byr'
  and fields ? 'iyr'
  and fields ? 'eyr'
  and fields ? 'hgt'
  and fields ? 'hcl'
  and fields ? 'ecl'
  and fields ? 'pid'
  -- and fields ? 'cid'
;
