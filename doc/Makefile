##### Environment setup
# directory
TOPDIR			= ..
ADOCDIR			= asciidoc
HTMLDIR 		= html
YAMLDIR			= yaml
DESIGNDIR		= $(YAMLDIR)/design
PYDIR			= scripts
# files
DIRFILE			= dir.yml
HIERFILE		= design_hier.yml

vpath %.adoc	= $(ADOCDIR)
vpath %.html	= $(HTML)
vpath %.yml		= $(YAMLDIR)

all: dir.yml incdir.yml srcdir.yml files.yml design_hier.yml
#all: dir.yml incdir.yml files.yml
#all: dir.yml design_hier.yml

%.html: %.adoc

%.adoc: $(DIRFILE)
	mkdir -p $(ADOCDIR)
	./make_adoc.sh -i $(YAMLDIR)/$(DIRFILE) $(@:.adoc=)

files.yml: dir.yml
	python3 ${PYDIR}/parse_file.py -c $(YAMLDIR)/parse_conf.yml -d ${YAMLDIR}/dir.yml -o $(YAMLDIR)/$@

design_hier.yml: srcdir.yml incdir.yml
	mkdir -p $(DESIGNDIR)
	python3 ${PYDIR}/parse_design.py -c $(YAMLDIR)/parse_conf.yml -t $(YAMLDIR)/design \
		-i $(YAMLDIR)/incdir.yml -d $(YAMLDIR)/srcdir.yml -o $(YAMLDIR)/$@
	python3 ${PYDIR}/construct_design_hier.py 

# dir.yml, incdir.yml srcdir.yml
%.yml:
	python3 ${PYDIR}/parse_dir.py -c $(YAMLDIR)/parse_conf.yml -t $(@:.yml=) -o $(YAMLDIR)/$@

.PHONY: clean
clean:
	rm -f $(YAMLDIR)/dir.yml
	rm -f $(YAMLDIR)/incdir.yml
	rm -f $(YAMLDIR)/srcdir.yml
	rm -f $(YAMLDIR)/files.yml
	rm -f $(YAMLDIR)/design_hier.yml
	rm -rf $(YAMLDIR)/design
