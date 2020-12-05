package main

import (
	"fmt"

	"github.com/Jell/advent2020/utils"
)

func massToFuel(mass int) int {
	var fuel = (mass / 3) - 2
	if fuel <= 0 {
		return 0
	}
	return fuel + massToFuel(fuel)
}

func main() {
	lines := utils.ReadLines("../../inputs/day01.txt")
	expenses := utils.StrsToInts(lines)
	expensesSet := map[int]bool{}

	for _, expense := range expenses {
		expensesSet[expense] = true
	}

	solution := 0

	for ia, a := range expenses {
		for _, b := range expenses[ia+1:] {
			c := 2020 - a - b
			if expensesSet[c] {
				solution = a * b * c
				break
			}
		}
	}

	fmt.Println("Day 01 - Part 2:", solution)
}
