PYTHON=python
DEFAULT_PREFIX_MAP="https://raw.githubusercontent.com/bioregistry/bioregistry/main/docs/_data/contexts/obo_synonyms.context.jsonld"

all: test

EXTS = _datamodel.py .graphql .schema.json .owl -docs .shex .context.jsonld .external.context.jsonld

all_schema: $(patsubst %,schema/sssom%, $(EXTS))


schema/%_datamodel.py: schema/%.yaml
	gen-py-classes $< > $@
schema/%.graphql: schema/%.yaml
	gen-graphql $< > $@
schema/%.schema.json: schema/%.yaml
	gen-json-schema -t 'mapping set' $< > $@
schema/%.shex: schema/%.yaml
	gen-shex $< > $@
schema/sssom.external.context.jsonld:
	wget $(DEFAULT_PREFIX_MAP) -O $@
schema/%.context.jsonld: schema/%.yaml
	gen-jsonld-context $< > $@
schema/%.csv: schema/%.yaml
	gen-csv $< > $@
schema/%.owl: schema/%.yaml
	gen-owl $< > $@
schema/%.ttl: schema/%.owl
	cp $< $@
schema/%-docs: schema/%.yaml
	pipenv run gen-markdown --dir $@ $<

test:
	pytest
	sh tests/tests.sh


deploy-dm:
	cp schema/sssom_datamodel.py sssom/
	cp schema/sssom.context.jsonld sssom/
	cp schema/sssom.external.context.jsonld sssom/

# # run after tests
# deploy-schema:
# 	cp tests/data/sssom.yaml schema/

copy-spec:
	cp ../SSSOM/sssom_metadata.tsv tests/data

install:
	$(PYTHON) setup.py install
	pip install -r requirements.txt
	pip install .[test]

pypi: test
	echo "Uploading to pypi. Make sure you have twine installed.."
	python setup.py sdist
	twine upload dist/*

lint:
	pip install tox
	tox -e lint
