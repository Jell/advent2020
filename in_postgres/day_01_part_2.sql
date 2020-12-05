DROP TABLE IF EXISTS dec01;

CREATE TABLE dec01 (
    line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    value bigint NOT NULL
);

\COPY dec01 (value) FROM PROGRAM 'cat ../inputs/day01.txt';
VACUUM ANALYZE dec01;

CREATE INDEX ON dec01 (value, line_number);

\timing on

SELECT concat('Day 01 - Part 2: ', (a.value * b.value * c.value))
from dec01 as a, dec01 as b, dec01 as c
where
    a.value <= 2020
and b.value <= 2020 - a.value
and c.value  = 2020 - a.value - b.value
and a.line_number < b.line_number
and b.line_number < c.line_number
limit 1;
