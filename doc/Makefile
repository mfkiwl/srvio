##### Environment setup
# directory
TOPDIR			= ..
ADOCDIR			= asciidoc
HTMLDIR 		= html
CONFDIR			= conf
YAMLDIR			= yaml
DESIGNDIR		= $(YAMLDIR)/design
SCRIPTDIR		= scripts
PREPROCDIR		= preproc
# files
DIRFILE			= dir.yml
DBFILE			= design.db

vpath %.adoc	= $(ADOCDIR)
vpath %.html	= $(HTML)
vpath %.yml		= $(YAMLDIR)

all: dir.yml incdir.yml srcdir.yml files.yml design_hier
#all: preproc

%.html: %.adoc

%.adoc: $(DIRFILE)
	mkdir -p $(ADOCDIR)
	./make_adoc.sh -i $(YAMLDIR)/$(DIRFILE) $(@:.adoc=)

files.yml: dir.yml
	mkdir -p $(YAMLDIR)
	python3 ${SCRIPTDIR}/parse_file.py \
	-c $(CONFDIR)/parse_conf.yml -d ${YAMLDIR}/dir.yml -o $(YAMLDIR)/$@

# dir.yml, incdir.yml srcdir.yml
%.yml:
	mkdir -p $(YAMLDIR)
	python3 ${SCRIPTDIR}/parse_dir.py \
	-c $(CONFDIR)/parse_conf.yml -t $(@:.yml=) -o $(YAMLDIR)/$@

design_hier: srcdir.yml incdir.yml
	mkdir -p $(YAMLDIR)
	mkdir -p $(DESIGNDIR)
	python3 ${SCRIPTDIR}/parse_design.py \
		-c $(CONFDIR)/parse_conf.yml -t $(DESIGNDIR) \
		-i $(YAMLDIR)/incdir.yml -d $(YAMLDIR)/srcdir.yml \
		-o $(DBFILE)
	python3 ${SCRIPTDIR}/design_hier.py \
		-i $(DBFILE) -t $(CONFDIR)/top.yml -o $(YAMLDIR)

preproc: srcdir.yml
	mkdir -p $(PREPROCDIR)
	python3 ${SCRIPTDIR}/preproc.py \
		-c $(CONFDIR)/parse_conf.yml -i $(YAMLDIR)/incdir.yml \
		-s $(YAMLDIR)/srcdir.yml -d $(PREPROCDIR)

clean:
	rm -f $(DBFILE)
	rm -rf $(YAMLDIR)
	rm -rf $(PREPROCDIR)

.PHONY: design_hier clean preproc
