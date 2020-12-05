.DEFAULT_GOAL := all

MAIN_FILES := $(wildcard ./src/*.ts)

DIFFS := $(shell cd "src" && ls | grep -e "day_.._part." | grep -o "day_.." | sort | uniq)

package.json:

node_modules: package.json
	yarn install

.PHONY: $(MAIN_FILES) $(DIFFS) README.md

$(MAIN_FILES): node_modules
	yarn ts-node $@

README.md:
	echo "# In TypeScript\n" > README.md

$(DIFFS): README.md
	../diff.sh $@ src/$@_part_1.ts src/$@_part_2.ts

all: $(MAIN_FILES) $(DIFFS)
