DROP SCHEMA IF EXISTS day08 CASCADE;

CREATE SCHEMA IF NOT EXISTS day08;

CREATE UNLOGGED TABLE day08.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day08.inputs (line_value) FROM PROGRAM 'cat ../inputs/day08.txt';
VACUUM ANALYZE day08.inputs;

\timing on

with recursive program as (
  select line_number, line_value, op, arg
  from day08.inputs,
  lateral (select split_part(line_value, ' ', 1),
                  split_part(line_value, ' ', 2)::int) as instruction(op, arg)
), runtime(iteration, instruction, pointer, accumulator, lines) as (
   select 0, '', 1, 0, '{}'::bigint[]
   union
   select iteration+1,
          line_value,
          case op
          when 'jmp' then pointer + arg
          else pointer + 1
          end,
          case op
          when 'acc' then accumulator + arg
          else accumulator
          end,
          array_append(lines, line_number)
   from runtime,
   lateral (select line_number, line_value, op, arg from program where line_number = pointer) as instruction
   where iteration < 1000
   and not (line_number = ANY(lines))
) select concat('Day 08 - Part 1: ', accumulator)
  from runtime
  order by iteration desc
  limit 1
;
