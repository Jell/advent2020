.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./**/main.go)

DIFFS := $(shell ls | grep -e "day_.._part_." | grep -o "day_.." | uniq)

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES):
	cd $(dir $@) && go run $(notdir $@)

README.md:
	echo "# In Go\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ $@_part_1/main.go $@_part_2/main.go

all: $(MAIN_FILES) $(DIFFS)
