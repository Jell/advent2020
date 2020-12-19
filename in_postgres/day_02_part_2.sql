DROP SCHEMA IF EXISTS day02 CASCADE;

CREATE SCHEMA IF NOT EXISTS day02;

CREATE UNLOGGED TABLE day02.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day02.inputs (line_value) FROM PROGRAM 'cat ../inputs/day02.txt';
VACUUM ANALYZE day02.inputs;

\timing on

SELECT concat('Day 02 - Part 2: ', count(*))
FROM day02.inputs i,
LATERAL (select regexp_matches(i.line_value, '(\d+)-(\d+) (.): (.*)')) as parts,
LATERAL (select parts.regexp_matches[1]::int as "min",
                parts.regexp_matches[2]::int as "max",
                parts.regexp_matches[3] as "char") as policy,
LATERAL (select parts.regexp_matches[4] as "value") as password,
LATERAL (select regexp_split_to_array(password."value", '') as "chars") as checksum
WHERE (checksum.chars[policy.min] = policy.char) <> (checksum.chars[policy.max] = policy.char)
;
