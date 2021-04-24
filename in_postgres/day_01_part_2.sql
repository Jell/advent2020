DROP TABLE IF EXISTS day01;

CREATE UNLOGGED TABLE day01 (
    line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    value bigint NOT NULL
);

\COPY day01 (value) FROM PROGRAM 'cat ../inputs/day01.txt';
VACUUM ANALYZE day01;

CREATE INDEX ON day01 (value, line_number);

\timing on

SELECT concat('Day 01 - Part 2: ', (a.value * b.value * c.value))
from day01 as a, day01 as b, day01 as c
where
    a.value <= 2020
and b.value <= 2020 - a.value
and c.value  = 2020 - a.value - b.value
and a.line_number < b.line_number
and b.line_number < c.line_number
limit 1;
