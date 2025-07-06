venv:
	python3 -m venv venv
dependencies:
	# python requirements
	source venv/bin/activate; if [[ ! -s $requirements.txt ]]; then \
		pip install -r requirements.txt; \
	fi
	# Ansible roles
	mkdir -p roles
	source venv/bin/activate; if [[ ! -s $galaxy_requirements.yml ]]; then \
		ansible-galaxy install -r galaxy_requirements.yml --roles-path roles; \
	fi
