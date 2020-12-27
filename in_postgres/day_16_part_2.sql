DROP SCHEMA IF EXISTS day16 CASCADE;

CREATE SCHEMA IF NOT EXISTS day16;

CREATE UNLOGGED TABLE day16.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day16.inputs (line_value) FROM PROGRAM 'cat ../inputs/day16.txt';
VACUUM ANALYZE day16.inputs;

\timing on

with recursive parts as (
  select line_number,
         line_value as string,
         count(*) filter (where line_value = '') over (order by line_number) as part
  from day16.inputs
  where line_value != 'your ticket:'
  and line_value != 'nearby tickets:'
), rules as (
  select
    rule.regexp_matches[1] as field,
    rule.regexp_matches[2]::int as range1_min,
    rule.regexp_matches[3]::int as range1_max,
    rule.regexp_matches[4]::int as range2_min,
    rule.regexp_matches[5]::int as range2_max
  from parts,
  lateral (select regexp_matches(string, '^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)$')) as rule
  where part = 0
  and string != ''
), my_ticket as (
  select row_number() over (partition by line_number) as pos,
         field.value::int as field_value
  from parts,
  lateral (select regexp_split_to_table(string, ',')) as field(value)
  where part = 1
  and string != ''
), nearby_tickets as (
  select line_number as ticket_id,
         field.value::int as field_value,
         row_number() over (partition by line_number) as pos
  from parts,
  lateral (select regexp_split_to_table(string, ',')) as field(value)
  where part = 2
  and string != ''
), invalid_fields as (
  select *
  from nearby_tickets
  where not exists (
    select 1
    from rules
    where nearby_tickets.field_value between rules.range1_min and rules.range1_max
    or    nearby_tickets.field_value between rules.range2_min and rules.range2_max
  )
), valid_tickets as (
  select *
  from nearby_tickets
  where not exists (select 1 from invalid_fields where invalid_fields.ticket_id = nearby_tickets.ticket_id)
), initial_constraints as (select pos,
         rules.field
  from valid_tickets
  cross join rules
  group by pos, rules.field
  having count(*) = count(*) filter (
    where field_value between rules.range1_min and rules.range1_max
    or    field_value between rules.range2_min and rules.range2_max
  )
), solver(gen, pos, field) as (
  select 0, *
  from initial_constraints
  where not exists (
    select 1 from initial_constraints other
    where other.pos = initial_constraints.pos
    and other.field != initial_constraints.field
  )
  union
  (
    with solved(gen, pos, field) as (table solver)
    select (select max(gen)+1 from solved), initial_constraints.*
    from initial_constraints
    left outer join solved is_solved on is_solved.field = initial_constraints.field
    where not exists (
      select 1 from initial_constraints other
      where other.pos = initial_constraints.pos
      and other.field not in (select field from solved)
      and other.pos not in (select pos from solved)
      and other.field != initial_constraints.field
    ) and (is_solved.pos is null or is_solved.pos = initial_constraints.pos)
  )
), my_ticket_solution as (
  select rules.field, solved_pos.value as field_pos, solved_value.value::bigint as field_value
  from rules,
  lateral (select pos from solver where rules.field = solver.field limit 1) as solved_pos(value),
  lateral (select field_value from my_ticket where my_ticket.pos = solved_pos.value) as solved_value(value)
  where rules.field like 'departure%'
), product(seen, acc) as (
  select array[]::text[], 1::bigint
  union
  select array_append(seen, field), acc*next.field_value
  from product,
  lateral (select field_value, field from my_ticket_solution where not field = ANY(seen) limit 1) as next
) select concat('Day 16 - Part 2: ', max(acc))
  from product
;
