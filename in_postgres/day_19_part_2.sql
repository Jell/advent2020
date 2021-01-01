DROP SCHEMA IF EXISTS day19 CASCADE;

CREATE SCHEMA IF NOT EXISTS day19;

CREATE UNLOGGED TABLE day19.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day19.inputs (line_value) FROM PROGRAM 'cat ../inputs/day19.txt';
VACUUM ANALYZE day19.inputs;

\timing on

with recursive rule8(i, pattern, next_val) as (
  select 1, '( 42 )', '42 42'
  union
  select i+1, concat(pattern, ' | ( ', next_val, ' )'), concat(next_val, ' 42')
  from rule8
), rule11(i, pattern, next_val) as (
  select 1, '( 42 31 )', '42 42 31 31'
  union
  select i+1, concat(pattern, ' | ( ', next_val, ' )'), concat('42 ', next_val, ' 31')
  from rule11
), fixed_inputs(rule_id, rule_pattern) as (
  (select '8', pattern from rule8 where i = 8 limit 1)
  union
  (select '11', pattern from rule11 where i = 5 limit 1)
  union
  select rule.parts[1] as rule_id, rule.parts[2]
  from day19.inputs,
  lateral (select regexp_matches(line_value, '^(\d+): (.*)$')) as rule(parts)
  where rule.parts[1] <> '8' and rule.parts[1] <> '11'
), rules as (
  select rule_id,
         lpad(pattern.index::text, 3, '0') as index,
         pattern.token as pattern_token
  from fixed_inputs,
  lateral (select case
                  when rule_pattern ~ '"a"' then 'a'
                  when rule_pattern ~ '"b"' then 'b'
                  else concat('( ', rule_pattern, ' )')
                  end) as pattern_part(string),
  lateral (select *
           from regexp_split_to_table(pattern_part.string, ' ')
           with ordinality) as pattern(token, index)
), messages as (
   select line_value as message
   from day19.inputs
   where line_value ~ '^(a|b)+$'
), rules_tree as (
  select index, pattern_token from rules where rule_id = '0'
  union
  select concat(r.index::text, o.index::text),
         coalesce(o.pattern_token, r.pattern_token)
  from rules_tree r
  left outer join rules o on o.rule_id = r.pattern_token
), regexp as (
  select concat('^', string_agg(pattern_token, '' order by index), '$') pattern
  from rules_tree
  where not pattern_token ~ '\d+'
) select concat('Day 19 - Part 2: ', count(*))
  from regexp, messages
  where message ~ pattern
;
