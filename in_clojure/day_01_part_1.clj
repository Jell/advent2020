#!/usr/bin/env bb

(require '[clojure.string :as str])

(def input
  (->> "../inputs/day01.txt"
       (slurp)
       (str/split-lines)
       (map read-string)
       set))

(def solution
  (some identity
        (for [a input]
          (when-let [b ((disj input a) (- 2020 a))]
            (* a b)))))

(println "Day 01 - Part 1:" solution)
