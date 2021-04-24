DROP SCHEMA IF EXISTS day04 CASCADE;

CREATE SCHEMA IF NOT EXISTS day04;

CREATE UNLOGGED TABLE day04.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day04.inputs (line_value) FROM PROGRAM 'cat ../inputs/day04.txt';
VACUUM ANALYZE day04.inputs;

\timing on

with  passport_lines(pass_id, i, line) as (
   select max(line_number) filter (where line_value = '') over (order by line_number),
          line_number,
          line_value
   from day04.inputs
), passports as (
  select pass_id, jsonb_object_agg(tags.key, tags.value) as fields
  from passport_lines,
  lateral (select regexp_split_to_table(line, ' ')) as label(val),
  lateral (select split_part(label.val, ':', 1) as "key", split_part(label.val, ':', 2) as value) as tags
  where line <> ''
  group by pass_id
) select concat('Day 04 - Part 2: ', count(*))
  from passports
  where fields ? 'byr'
  and fields ? 'iyr'
  and fields ? 'eyr'
  and fields ? 'hgt'
  and fields ? 'hcl'
  and fields ? 'ecl'
  and fields ? 'pid'
  and fields->>'byr' ~ '^\d{4}$'
  and (fields->>'byr')::int between 1920 and 2002
  and fields->>'iyr' ~ '^\d{4}$'
  and (fields->>'iyr')::int between 2010 and 2020
  and fields->>'eyr' ~ '^\d{4}$'
  and (fields->>'eyr')::int between 2020 and 2030
  and (
    (fields->>'hgt' ~ '^\d+cm$' and split_part(fields->>'hgt', 'cm', 1)::int between 150 and 193)
    or
    (fields->>'hgt' ~ '^\d+in$' and split_part(fields->>'hgt', 'in', 1)::int between 59 and 76)
  )
  and fields->>'hcl' ~ '^#[0-9a-f]{6}$'
  and fields->>'ecl' ~ '^amb|blu|brn|gry|grn|hzl|oth$'
  and fields->>'pid' ~ '^\d{9}$'
  -- and fields ? 'cid'
;
