DROP SCHEMA IF EXISTS day18 CASCADE;

CREATE SCHEMA IF NOT EXISTS day18;

CREATE UNLOGGED TABLE day18.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day18.inputs (line_value) FROM PROGRAM 'cat ../inputs/day18.txt';
VACUUM ANALYZE day18.inputs;

\timing on

with recursive formulas as (
  select line_number as formula_id,
         c.value as token,
         row_number() over (partition by line_number) as pos
  from day18.inputs,
  lateral (select regexp_split_to_table(line_value, '')) as c(value)
  where c.value != ' '
), calculator(i, id, val_stack, op_stack, val, op) as (
  select 0, formula_id, array[]::bigint[], array[]::text[], 0::bigint, '+' from formulas
  union
  select i+1,
         id,
         -- val_stack
         case
         when next.token = '('
         then array_prepend(val, val_stack)
         when next.token = ')'
         then (select array_agg(i) from (select unnest(val_stack) offset 1) x(i))
         else val_stack
         end,
         -- op_stack
         case when next.token = '(' then array_prepend(op, op_stack)
         when next.token = ')'
         then (select array_agg(i) from (select unnest(op_stack) offset 1) x(i))
         else op_stack
         end,
         -- val
         case
         when next.token = '(' then 0
         when next.token ~ '\d' and op = '+' then next.token::bigint + val
         when next.token ~ '\d' and op = '*' then next.token::bigint * val
         when next.token = ')'
         then (case (select unnest(op_stack) limit 1)
               when '+' then val + (select unnest(val_stack) limit 1)
               when '*' then val * (select unnest(val_stack) limit 1)
               end)
         else val
         end,
         -- op
         case
         when next.token = '(' then '+'
         when next.token ~ '[+*]' then next.token
         when next.token = ')' then (select unnest(op_stack) limit 1)
         else op
         end
  from calculator,
  lateral (select * from formulas where pos = i+1 and formula_id = id) as next
) select concat('Day 18 - Part 1: ', sum(val))
  from calculator,
  lateral (select max(i) from calculator c where c.id = calculator.id) as iteration(last)
  where i = iteration.last
;
