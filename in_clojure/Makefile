.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./*.clj)

DIFFS := $(shell ls | grep -e "day_.._part." | grep -o "day_.." | sort | uniq)

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES):
	./$@

README.md:
	echo "# In Clojure\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ $@_part_1.clj $@_part_2.clj

all: $(MAIN_FILES) $(DIFFS)
