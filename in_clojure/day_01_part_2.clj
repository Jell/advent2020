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
        (for [a input b (disj input a)]
          (when-let [c ((disj input a b)
                        (- 2020 a b))]
            (* a b c)))))

(time
 (println "Day 01 - Part 2:" solution))
