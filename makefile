PACKAGE_NAME := $(shell cat info.json|jq -r .name)
VERSION_STRING := $(shell cat info.json|jq -r .version)
TOKEN := $(shell cat .token)
OUTPUT_NAME := $(PACKAGE_NAME)_$(VERSION_STRING)
BUILD_DIR := .build
OUTPUT_DIR := $(BUILD_DIR)/$(OUTPUT_NAME)
CONFIG = ./$(OUTPUT_DIR)/config.lua
MODS_DIRECTORY := ../.mods.15
##MOD_LINK := $(shell find $(MODS_DIRECTORY)/$(OUTPUT_NAME) -mindepth 1 -maxdepth 1 -type d)
PARSER := ". | map(select(.tag_name == \"$(VERSION_STRING)\"))[0].assets | map(select(.name == \"$(OUTPUT_NAME).zip\"))[0].id"

PKG_COPY := $(wildcard *.md) $(wildcard .*.md) $(wildcard graphics) $(wildcard locale) $(wildcard sounds)

SED_FILES := $(shell find . -iname '*.json' -type f -not -path "./.*/*") $(shell find . -iname '*.lua' -type f -not -path "./.*/*")
PNG_FILES := $(shell find ./graphics -iname '*.png' -type f)

OUT_FILES := $(SED_FILES:%=$(OUTPUT_DIR)/%)

SED_EXPRS := -e 's/{{_MOD_NAME_}}/$(PACKAGE_NAME)/g'
SED_EXPRS += -e 's/{{_MOD_VERSION_}}/$(VERSION_STRING)/g'

all: clean

release: clean check package

optimized-release: clean check tag optimize-package

package-copy: $(PKG_DIRS) $(PKG_FILES)
	@mkdir -p $(OUTPUT_DIR)
ifneq ($(PKG_COPY),)
	@cp -r $(PKG_COPY) $(OUTPUT_DIR)
endif

$(OUTPUT_DIR)/%.lua: %.lua
	@mkdir -p $(@D)
	@sed $(SED_EXPRS) $< > $@

$(OUTPUT_DIR)/%: %
	@mkdir -p $(@D)
	@sed $(SED_EXPRS) $< > $@

update-stdlib:
	#copy stdlib-files from branch
	git add stdlib/
	git commit -m "STDLIB Update"

tag:
	git tag -f v$(VERSION_STRING)

optimize:
	@echo Please wait, Optimizing Graphics.
	@for name in $(PNG_FILES); do \
		pngquant --skip-if-larger -q --strip --ext .png --force $(OUTPUT_DIR)'/'$$name; \
	done

nodebug:
	@[ -e $(CONFIG) ] && \
	echo Removing debug switches from config.lua && \
	sed -i 's/^\(.*DEBUG.*=\).*/\1 false/' $(CONFIG) && \
	sed -i 's/^\(.*LOGLEVEL.*=\).*/\1 0/' $(CONFIG) && \
	sed -i 's/^\(.*loglevel.*=\).*/\1 0/' $(CONFIG) || \
	echo No Config Files

check:
	@luacheck . -q --codes

package: package-copy $(OUT_FILES) nodebug
	@cd $(BUILD_DIR) && zip -rq $(OUTPUT_NAME).zip $(OUTPUT_NAME)
	@echo $(OUTPUT_NAME).zip ready

optimize-package: package-copy $(OUT_FILES) nodebug optimize tag
	@cd $(BUILD_DIR) && zip -rq $(OUTPUT_NAME).zip $(OUTPUT_NAME)
	@echo $(OUTPUT_NAME).zip ready

clean:
	@rm -rf $(BUILD_DIR)
	@echo Removing Build Directory.
