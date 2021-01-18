
.PHONY: all

.PHONY: docs
docs:
	mkdir -p dist/doc/bash
	for inc in $$(find bash -name \*.sh); do \
		mdname=$$(echo $$inc | sed -e 's/\.sh/\.md/') ; \
		bashadoc $$inc > dist/doc/$$mdname ; done

.PHONY: clean
clean:
	rm -f dist

.PHONY: test
