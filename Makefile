SRC = src
OUT = public
CSS = style.css
TPL = template.html


MD := $(shell find $(SRC) -name '*.md')
HTML := $(MD:$(SRC)/%.md=$(OUT)/%.html)


all: $(HTML) assets


$(OUT)/%.html: $(SRC)/%.md
	@mkdir -p $(dir $@)
	pandoc $< \
	--template=$(TPL) \
	--css=/style.css \
	--standalone \
	-o $@


assets:
	cp $(CSS) $(OUT)/style.css


clean:
	rm -rf $(OUT)
