DROP SCHEMA IF EXISTS day19 CASCADE;

CREATE SCHEMA IF NOT EXISTS day19;

CREATE UNLOGGED TABLE day19.inputs (
  line_number bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
  line_value text NOT NULL
);

\COPY day19.inputs (line_value) FROM PROGRAM 'cat ../inputs/day19.txt';
VACUUM ANALYZE day19.inputs;

\timing on

with recursive rules as (
  select rule.parts[1] as rule_id,
         pattern.index as index,
         pattern.token as pattern_token
  from day19.inputs,
  lateral (select regexp_matches(line_value, '^(\d+): (.*)$')) as rule(parts),
  lateral (select case
                  when rule.parts[2] ~ '"a"' then 'a'
                  when rule.parts[2] ~ '"b"' then 'b'
                  else concat('( ', rule.parts[2], ' )')
                  end) as pattern_part(string),
  lateral (select *
           from regexp_split_to_table(pattern_part.string, ' ')
           with ordinality) as pattern(token, index)
), messages as (
   select line_value as message
   from day19.inputs
   where line_value ~ '^(a|b)+$'
), rules_tree as (
  select index::text, pattern_token from rules where rule_id = '0'
  union
  select concat(r.index::text, o.index::text),
         coalesce(o.pattern_token, r.pattern_token)
  from rules_tree r
  left outer join rules o on o.rule_id = r.pattern_token
), regexp as (
  select concat('^', string_agg(pattern_token, '' order by index), '$') pattern
  from rules_tree
  where not pattern_token ~ '\d+'
) select concat('Day 19 - Part 1: ', count(*))
  from regexp, messages
  where message ~ pattern
;
