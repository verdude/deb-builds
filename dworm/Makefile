.PHONY: img
img:
	cp ../pkgbuild.sh .
	cp ../control .
	docker build -t verdude/dworm-deb .

.PHONY: build
build:
	docker run --init verdude/dworm-deb

.PHONY: clean
clean:
	git clean -xdff
