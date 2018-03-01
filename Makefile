all:
	cd fsbook-case-study && make
	cd fsbook-references && make
	cd fsbook-basics && make

docker:
	docker pull dujinfang/texlive_pandoc

dockerrun:
	docker run --rm -it -v ${PWD}:/team dujinfang/texlive_pandoc bash
