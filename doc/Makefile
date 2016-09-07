build::
	docker run --rm -v `pwd`:/documents moird/mkdocs mkdocs build
	docker run --rm -v `pwd`:/var/output busybox chown `id -u`:`id -g` /var/output/ -R
	docker build -t horgix/click-count-doc .
