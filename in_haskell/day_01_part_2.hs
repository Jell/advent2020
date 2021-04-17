#!/usr/bin/env -S stack --resolver lts-14.14 runghc

-- when running in ghci:
-- :cd ~/DevPerso/advent2020/in_haskell

import Control.Category
import Data.Function

parseInt :: String -> Int
parseInt x = read $ filter (`elem` "-0123456789") x

loadInput :: IO ([Int])
loadInput = do
  raw <- readFile "../inputs/day01.txt"
  return $ map parseInt $ lines raw

solve :: [Int] -> Int
solve expenses = head $ [a * b | a <- expenses, b <- expenses, a + b == 2020]

main :: IO ()
main = do
  input <- loadInput
  putStr "Day 01 - Part 2: "
  putStrLn $ show $ head $ [a * b * c | a <- input,
                                        b <- input,
                                        c <- input,
                                        a + b + c == 2020]
