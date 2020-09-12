SRC = $(wildcard *.md)
HTML = $(SRC:%.md=out/%.html)
TEX = $(SRC:%.md=out/%.tex)
XTEX = $(SRC:%.md=out/x%.tex)
PDF = $(SRC:%.md=out/%.pdf)
DOCS = $(SRC:%.md=out/%.docx)
MD = markdown
PANDOC = /usr/local/bin/pandoc
PANDOC = pandoc
IMGSRC = $(wildcard images/*.msc)
PNG = $(IMGSRC:%.msc=../%.png)
SVG = $(IMGSRC:%.msc=%.svg)
INCSCAPE = /Applications/Inkscape.app/Contents/Resources/bin/inkscape
# INCDPI = -d 300
VER=0
NAME=FreeSWITCH参考手册

all: html pdf

SRC=meta.md \
	chapter1.md \
	chapter2.md \
	chapter3.md \
	chapter4.md \
	chapterX.md \
	postface.md

.PHONY html: $(SRC)
	cp -R images out/
	$(PANDOC) --toc -o out/$(NAME)-$(VER).html \
	--variable book="FreeSWITCH参考手册" \
	--variable title="FreeSWITCH参考手册" \
	--template cover.html \
	$(SRC)

out/%.html: %.md
	# cat ../templates/header.html > $@
	# $(MD) < $< >> $@
	# cat ../templates/footer.html >> $@
	$(PANDOC) -o $@ --template cover.html $<

clean:
	rm -f out/*.pdf
	rm -f out/*.tex
	rm -f out/*.docx
	rm -f out/*.epub
	rm -f out/*.jpb
	rm -f out/*.png
	rm -f out/*.html
	rm -rf out/images

# --include-before-body=header.tex \
# --variable documentclass="book" \
# --variable author="Seven Du" \
# --variable title="FreeSWITCH: VoIP in Action" \


htmls: $(HTML)

../html/%.html: %.md
	$(PANDOC) -s -c css/style.css -o $@ $<

tex: $(TEX)

out/%.tex: %.md
	$(PANDOC) -s --variable documentclass="report" \
	--template ../templates/body.tex -o $@ $<

xtex: $(XTEX)

out/x%.tex: %.md
	$(PANDOC) -s --variable documentclass="report" \
	--template ../templates/latex.tex -o $@ $<

docs: $(DOCS)

out/%.docx: %.md
	$(PANDOC) -s -o $@ $<


pdfs: $(PDF)

out/preface.tex: preface.md
	$(PANDOC) -s --toc --variable documentclass="report" \
	--template ../templates/preface.tex \
	-o out/preface.tex preface.md
	# sed -i -e '1s/chapter{/chapter*{/' preface.tex

pdf: $(SRC) out/preface.tex cover.tex cover-back.tex

	$(PANDOC) -s --toc --variable documentclass="report" \
	--variable book="FreeSWITCH参考手册" \
	--template cover.tex \
	--number-sections \
	--pdf-engine=xelatex \
	--include-in-header=ncover.tex \
	--include-before-body=out/preface.tex \
	--include-after-body=cover-back.tex \
	-o out/$(NAME)-$(VER).pdf \
	$(SRC)

print:
	@echo this book is not printable!

out/%.pdf: %.md
	$(PANDOC) -s --toc --variable documentclass="report" \
	--variable book="FreeSWITCH参考手册" \
	--template cover.tex \
	--number-sections \
	--latex-engine=xelatex \
	--include-before-body=preface.tex \
	--include-after-body=cover-back.tex \
	-o $@ $<

epub:
	$(PANDOC) -s --toc -c kindle.css \
	--number-section \
	--epub-stylesheet=kindle.css \
	--epub-cover-image=images/cover.png \
	--epub-metadata=metadata.xml \
	--variable author="&#26460;&#37329;&#25151;" \
	--variable title="FreeSWITCH参考手册" \
	-o out/$(NAME)-$(VER).epub \
	$(SRC)

kindle:
	(cd out/ && kindlegen -gif fssrc-$(VER).epub)

imgs: $(PNG)
	echo $(PNG)

../images/%.png: ../images/%.svg
	# convert $@ $<
	$(INCSCAPE) -z -b FFFFFFFF $(INCDPI) -e $@ $<

../images/%.svg: images/%.msc
	#brew install mscgen
	mscgen -i $< -Tsvg -o $@

dotimgs:
	cd images && make dotpng


cover:
	$(PANDOC) -s --variable documentclass="report" \
	--template cover.tex \
	--number-sections \
	--variable mobile=true \
	--pdf-engine=xelatex \
	--include-in-header=xcover.tex \
	-o out/cover.pdf \
	meta.md
