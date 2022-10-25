OUTDIR := /tmp/

.PHONY: prep
prep:
	cp ../pkgbuild.sh .
	cp ../control .
	docker build --target=base -t verdude/dworm-deb-prep .

.PHONY: build
build:
	docker build --target=build -t verdude/dworm-deb .

.PHONY: copy-pkg
copy-pkg:
	docker run -ti -v $$PWD:/opt -e "LOCAL_USER_ID=$(shell id -u $$USER)" --rm verdude/dworm-deb bash -c "cp /tmp/*.deb /opt"

.PHONY: clean
clean:
	git clean -xdff
