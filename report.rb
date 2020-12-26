# -*- coding: utf-8 -*-

langs = Dir.glob('in_*').map { |d| d.gsub("in_", "") }.sort

solutions = {
  "Day 01" => { part1: "888331", part2: "130933530" },
  "Day 02" => { part1: "666", part2: "670" },
  "Day 03" => { part1: "274", part2: "6050183040" },
  "Day 04" => { part1: "206", part2: "123" },
  "Day 05" => { part1: "919", part2: "642" },
  "Day 06" => { part1: "6430", part2: "3125" },
  "Day 07" => { part1: "126", part2: "220149" },
  "Day 08" => { part1: "1766", part2: "1639" },
  "Day 09" => { part1: "88311122", part2: "13549369" },
  "Day 10" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 11" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 12" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 13" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 14" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 15" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 16" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 17" => { part1: "271", part2: "2064" },
  "Day 18" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 19" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 20" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 21" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 22" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 23" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 24" => { part1: "XXXXXXX", part2: "XXXXXXX" },
  "Day 25" => { part1: "XXXXXXX", part2: "XXXXXXX" },
}

results = {}
langs.each do |lang|
  puts "## #{lang}"
  results[lang] = `cd in_#{lang} && make 2> /dev/null`
  puts results[lang]
end

table = [
  [""] + langs,
  [":---:"] * (langs.count + 1)
] + solutions.map do |day, parts|
  [day] + langs.map do |lang|
    if results[lang].include?("#{day} - Part 1: #{parts.fetch(:part1)}")
      "*"
    else
      ""
    end +
    if results[lang].include?("#{day} - Part 2: #{parts.fetch(:part2)}")
      "*"
    else
      ""
    end
  end
end

report = table.map { |line| "|" + line.map { |c| c.ljust(10) }.join("|") + "|" }.join("\n")

puts ""
puts ""
puts "Progress:"
puts ""
puts report

readme = File.read("README.md")
readme[/\|.*\|/m] = report.tr("*","⭐")
File.write("README.md", readme)
