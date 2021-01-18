
.PHONY: all
all: clean docs packed

.PHONY: docs
docs:
	mkdir -p dist/doc/bash
	for inc in $$(find bash -name \*.sh); do \
		mdname=$$(echo $$inc | sed -e 's/\.sh/\.md/') ; \
		bashadoc $$inc > dist/doc/$$mdname ; done

.PHONY: packed
packed:
	mkdir dist/packed
	bash/pack-script -f bash/k8s-support-collector -o dist/packed/k8s-support-collector

.PHONY: clean
clean:
	rm -rf dist

.PHONY: test
