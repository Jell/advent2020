require 'set'

input = File.read("../inputs/day01.txt").lines.map(&:to_i).to_set

solution = nil
input.each do |a|
  input.each do |b|
    if input.include?(2020 - a - b)
      solution = a * b * (2020 - a - b)
      break
    end
  end
end

#--
puts "Day 01 - Part 2: #{solution}"
