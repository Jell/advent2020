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
), potential_fix as (
   select line_number as fix_line_number,
          case op
          when 'jmp' then 'nop'
          else 'jmp' end
          as fix_op
   from program
   where op = ANY('{"nop", "jmp"}'::text[])
), runtime(fix_line_number, fix_op, iteration, instruction, pointer, accumulator, lines, success) as (
   select fix_line_number, fix_op, 0, '', 1, 0, '{}'::bigint[], false from potential_fix
   union
   select fix_line_number,
          fix_op,
          iteration+1,
          line_value,
          next_line.number,
          case debugged.op
          when 'acc' then accumulator + arg
          else accumulator
          end,
          array_append(lines, line_number),
          not exists (select 1 from program where line_number = next_line.number)
   from runtime,
   lateral (select line_number, line_value, op, arg from program where line_number = pointer) as instruction,
   lateral (select case when line_number = fix_line_number then fix_op else op end as op) as debugged,
   lateral (select case debugged.op when 'jmp' then pointer + arg else pointer + 1 end) as next_line(number)
   where iteration < 10000
   and not (line_number = ANY(lines))
) select concat('Day 08 - Part 2: ', accumulator)
  from runtime
  where success = true
  limit 1
;
