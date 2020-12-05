.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./day*.cr)

DIFFS := $(shell ls | grep -e "day_.._part_." | grep -o "day_.." | uniq)

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES):
	crystal build $@ --release -o ./build/$(basename $@)
	./build/$(basename $@)

README.md:
	echo "# In Crystal\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ $@_part_1.cr $@_part_2.cr

all: $(MAIN_FILES) $(DIFFS)
