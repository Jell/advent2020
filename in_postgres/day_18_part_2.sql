DROP SCHEMA IF EXISTS day18 CASCADE;

CREATE SCHEMA IF NOT EXISTS day18;

CREATE UNLOGGED TABLE day18.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day18.inputs (line_value) FROM PROGRAM 'cat ../inputs/day18.txt';
VACUUM ANALYZE day18.inputs;

\timing on

with recursive calculator(line_number, computation, reduce_parens, reduce_plus, reduce_times_parens, reduce_times_top) as (
  select *, array[]::text[], array[]::text[], array[]::text[], array[]::text[] from day18.inputs
  union
  select calculator.line_number,
         case
         when parens is not null
         then concat(parens[1], parens[2], parens[3])
         when plus is not null
         then concat(plus[1], (plus[2]::bigint + plus[3]::bigint)::text, plus[4])
         when times_parens is not null
         then concat(times_parens[1], (times_parens[2]::bigint * times_parens[3]::bigint)::text, times_parens[4])
         when times_top is not null
         then concat((times_top[1]::bigint * times_top[2]::bigint)::text, times_top[3])
         else computation
         end,
         reduction.parens,
         reduction.plus,
         reduction.times_parens,
         reduction.times_top
  from calculator,
  lateral (select (select regexp_matches(computation, '^(.*?)\((\d+)\)(.*)$')) as parens,
                  (select regexp_matches(computation, '^(.*?)(\d+) \+ (\d+)(.*)$')) as plus,
                  (select regexp_matches(computation, '^(.*?\()(\d+) \* (\d+)((?: \* \d+)*\).*)$')) as times_parens,
                  (select regexp_matches(computation, '^(\d+) \* (\d+)((?: \* \d+)*)$')) as times_top
           from (VALUES (1)) x) as reduction
) select concat('Day 18 - Part 2: ', sum(computation::bigint))
  from calculator
  where reduce_parens is null
  and reduce_plus is null
  and reduce_times_parens is null
  and reduce_times_top is null
;
