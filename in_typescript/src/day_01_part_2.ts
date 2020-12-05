import { readFileSync } from 'fs';

let input: number[] = readFileSync('../inputs/day01.txt', "utf8").
    split("\n").
    map(i => parseInt(i)).
    slice(0, -1);

let expenses: Set<number> = new Set(input)

var solution: number = 0

expenses.forEach(a => {
    expenses.forEach(b => {
        let c = 2020 - a - b
        if (expenses.has(c)) {
            solution = a * b * c
        }
    })
})

console.log("Day 01 - Part 2:", solution)
