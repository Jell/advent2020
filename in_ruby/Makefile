.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./day*.rb)

DIFFS := $(shell ls | grep -e "day_.._part_." | grep -o "day_.." | uniq)

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES):
	ruby $@

README.md:
	echo "# In Ruby\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ $@_part_1.rb $@_part_2.rb

all: $(MAIN_FILES) $(DIFFS)
