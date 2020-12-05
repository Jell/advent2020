require 'set'

input = File.read("../inputs/day01.txt").lines.map(&:to_i).to_set

solution = nil
input.each do |a|
  if input.include?(2020 - a)
    solution = a * (2020 - a)
    break
  end
end

#--
puts "Day 01 - Part 1: #{solution}"
