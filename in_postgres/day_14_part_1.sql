DROP SCHEMA IF EXISTS day14 CASCADE;

CREATE SCHEMA IF NOT EXISTS day14;

CREATE UNLOGGED TABLE day14.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day14.inputs (line_value) FROM PROGRAM 'cat ../inputs/day14.txt';
VACUUM ANALYZE day14.inputs;

\timing on

with program as (
  select line_number,
         case
         when set_mask is not null then 'set_mask'
         when assign is not null then 'assign'
         end as op,
         replace(set_mask[1], 'X', '0')::bit(36) as set_or_mask,
         replace(set_mask[1], 'X', '1')::bit(36) as set_and_mask,
         assign[1]::numeric as assign_pointer,
         assign[2]::bigint::bit(36) as assign_value
  from day14.inputs,
  lateral (select (select regexp_match(line_value, '^mask = ([01X]+)$')) as set_mask,
                  (select regexp_match(line_Value, '^mem\[(\d+)\] = (\d+)$')) as assign) as instruction
), end_registers as (
  select distinct on (assign_pointer)
         assign_pointer as pointer,
         (assign_value & last_mask.and) | last_mask.or as value
  from program,
  lateral (select last_mask.set_or_mask as or, last_mask.set_and_mask as and
           from program last_mask
           where op = 'set_mask'
           and last_mask.line_number < program.line_number
           order by last_mask.line_number desc
           limit 1) as last_mask
  where op = 'assign'
  order by assign_pointer, line_number desc
) select concat('Day 14 - Part 1: ', sum(value::bigint))
  from end_registers;
