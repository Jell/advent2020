DROP SCHEMA IF EXISTS day03 CASCADE;

CREATE SCHEMA IF NOT EXISTS day03;

CREATE UNLOGGED TABLE day03.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day03.inputs (line_value) FROM PROGRAM 'cat ../inputs/day03.txt';
VACUUM ANALYZE day03.inputs;

\timing on

WITH RECURSIVE slopes AS (
  SELECT slope.right,
         slope.down,
         count(*) AS hits
  FROM day03.inputs i,
  (VALUES (1, 1), (3, 1), (5, 1), (7, 1), (1, 2)) AS slope ("right", down),
  LATERAL (SELECT char_length(i.line_value)::int AS "length",
                  string_to_array(i.line_value, null) AS chars) AS line,
  LATERAL (SELECT (((((i.line_number - 1) * slope.right) / slope.down) % line."length") + 1)::int AS pos) AS toboggan
  WHERE line.chars[toboggan.pos] = '#'
  AND (i.line_number - 1) % slope.down = 0
  GROUP BY slope.right, slope.down
), product(hits, res) AS (
  SELECT min(hits), min(hits) FROM slopes
  UNION
  SELECT slopes.hits, slopes.hits * product.res
  FROM product,
  LATERAL (SELECT * FROM slopes WHERE slopes.hits > product.hits ORDER BY slopes.hits LIMIT 1) slopes
) SELECT concat('Day 03 - Part 2: ', max(res)) FROM product
;
