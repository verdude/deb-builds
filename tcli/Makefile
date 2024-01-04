.PHONY: build
build: control pkgbuild.sh
	./pkgbuild.sh

control:
	cp ../control .

pkgbuild.sh:
	cp ../pkgbuild.sh .

.PHONY: clean
clean:
	git clean -xdff
