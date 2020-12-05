.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./*.hs)

DIFFS := $(shell ls | grep -e "day_.._part." | grep -o "day_.." | sort | uniq)

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES):
	./$@

README.md:
	echo "# In Haskell\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ $@_part_1.hs $@_part_2.hs

all: $(MAIN_FILES) $(DIFFS)
