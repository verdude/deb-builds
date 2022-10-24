img:
	cp ../pkgbuild.sh .
	cp ../control.template control
	docker build -t verdude/dworm-deb .

build:
	docker run verdude/dworm-deb
