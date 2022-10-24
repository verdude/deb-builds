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
	docker run -v $$PWD:/bin -e "LOCAL_USER_ID=$(shell -u $$USER)" --rm verdude/dworm-deb cp /opt/*.deb /bin

.PHONY: clean
clean:
	git clean -xdff
