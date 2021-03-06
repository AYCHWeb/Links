GRIP=grip

all: SPECMAP.json

SPECMAP.json: browser-compat-data \
  browser-compat-data/scripts/add-specs.js \
  .browser-compat-data-process.js
	node ./browser-compat-data/scripts/add-specs.js \
	  fullupdate 2>&1 \
	  | tee BCD-LOG
	node .browser-compat-data-process.js 2>&1 \
	  | tee LOG
	grep "Bad fragment" BCD-LOG || true
	grep "broken spec URL" BCD-LOG || true
	grep "malformed" BCD-LOG || true
	grep "error for" BCD-LOG || true
	grep "has bad spec URL" LOG || true
	grep " 404 " BCD-LOG || true
	grep " 404 " LOG || true

SPECURLS.json: .make-SPECURLS.js
	node --max-old-space-size=8192 .make-SPECURLS.js 2>&1 \
	  | tee URLS-LOG

index.html: README.md
	cp $< $<.tmp
	echo >> $<.tmp
	echo >> $<.tmp
	for file in *.json; do \
	    if [[ "$$file" != "MDNCOMP-DATA.json" && "$$file" != "SPECMAP.json" ]]; then \
	    echo "* [$${file%.*}]($$file) [[status](less-than-2.html?spec=$${file%.*})]" >> $<.tmp; \
	    fi; \
	done
	$(GRIP) --title=$< --export $<.tmp - > $@
	$(RM) $<.tmp
