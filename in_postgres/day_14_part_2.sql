DROP SCHEMA IF EXISTS day14 CASCADE;

CREATE SCHEMA IF NOT EXISTS day14;

CREATE UNLOGGED TABLE day14.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day14.inputs (line_value) FROM PROGRAM 'cat ../inputs/day14.txt';
VACUUM ANALYZE day14.inputs;

\timing on

with recursive program as (
  select line_number,
         case
         when set_mask is not null then 'set_mask'
         when assign is not null then 'assign'
         end as op,
         regexp_replace(set_mask[1], '[01]', '0','g') as set_float_mask,
         replace(set_mask[1], 'X', '0')::bit(36) as set_or_mask,
         assign[1]::bigint::bit(36) as assign_pointer,
         assign[2]::bigint::bit(36) as assign_value
  from day14.inputs,
  lateral (select (select regexp_match(line_value, '^mask = ([01X]+)$')) as set_mask,
                  (select regexp_match(line_Value, '^mem\[(\d+)\] = (\d+)$')) as assign) as instruction
), float_masks_iterations(id, m) as (
  select line_number, set_float_mask from program where op = 'set_mask'
  union (
    with previous as (table float_masks_iterations)
    select id, regexp_replace(m, 'X', '1')
    from previous
    union
    select id, regexp_replace(m, 'X', '0')
    from previous
  )
), float_masks as (
  select id, m::bit(36) as mask
  from float_masks_iterations
  where m ~ '^[01]+$'
), all_registers as (
  select program.line_number,
         (assign_pointer | last_mask.or) # float_mask.mask as pointer,
         assign_value as value
  from program,
  lateral (select last_mask.line_number,
                  last_mask.set_or_mask as or
           from program last_mask
           where op = 'set_mask'
           and last_mask.line_number < program.line_number
           order by last_mask.line_number desc
           limit 1) as last_mask,
  lateral (select mask
           from float_masks
           where float_masks.id = last_mask.line_number) as float_mask
  where op = 'assign'
), end_registers as (
  select distinct on(pointer) pointer::bigint, value::bigint
  from all_registers
  order by pointer, line_number desc
) select concat('Day 14 - Part 2: ', sum(value::bigint))
  from end_registers
;
