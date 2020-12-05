.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./day*.sql)

DIFFS := $(shell ls | grep -e "day_.._part_." | grep -o "day_.." | uniq)

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES):
	psql -h localhost -U root postgres < $@

README.md:
	echo "# In Postgres\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ $@_part_1.sql $@_part_2.sql

all: $(MAIN_FILES) $(DIFFS)
