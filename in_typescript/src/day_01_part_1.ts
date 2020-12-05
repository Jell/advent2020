import { readFileSync } from 'fs';

let input: number[] = readFileSync('../inputs/day01.txt', "utf8").
    split("\n").
    map(i => parseInt(i)).
    slice(0, -1);

let expenses: Set<number> = new Set(input)

var solution: number = 0

expenses.forEach(a => {
    if (expenses.has(2020 - a)) {
        solution = a * (2020 - a)
    }
})

console.log("Day 01 - Part 1:", solution)
