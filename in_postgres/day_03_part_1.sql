DROP SCHEMA IF EXISTS day03 CASCADE;

CREATE SCHEMA IF NOT EXISTS day03;

CREATE UNLOGGED TABLE day03.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day03.inputs (line_value) FROM PROGRAM 'cat ../inputs/day03.txt';
VACUUM ANALYZE day03.inputs;

\timing on

SELECT concat('Day 03 - Part 1: ', count(*))
FROM day03.inputs i,
LATERAL (SELECT char_length(i.line_value)::int AS "length",
                string_to_array(i.line_value, null) AS chars) AS line,
LATERAL (SELECT ((((i.line_number - 1) * 3) % line."length") + 1)::int AS pos) AS toboggan
WHERE line.chars[toboggan.pos] = '#'
;
