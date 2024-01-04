#
# Makefile: Commands to simplify deployments
#
# Examples:
#
#    make lint
#    make tests
#    make provision
#    make update
#
# The default inventory is for a production deployment. To provision
# a local virtual machine for development, override the inventory
# variable on the command line:
#
#    make inventory=development provision
#    make inventory=production update

# This is the system python
python := /usr/bin/env python3

# Where everything lives locally
root_dir := $(realpath .)
venv_dir = $(root_dir)/.venv

pip = $(venv_dir)/bin/pip3
pip-compile = $(venv_dir)/bin/pip-compile
pip-sync = $(venv_dir)/bin/pip-sync

# Ansible tools
ansible-playbook := $(venv_dir)/bin/ansible-playbook
ansible-lint := $(venv_dir)/bin/ansible-lint
molecule := $(venv_dir)/bin/molecule

# Inventory files
inventory = $(root_dir)/production
playbook = $(root_dir)/playbook.yml

# include additional targets or override variables from local makefiles
-include *.mk

.PHONY: help
help:
	@echo "The Makefile has the following targets..."
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

# ##############
#   Virtualenv
# ##############
#
# Create the virtualenv and install all the dependencies. If the virtualenv
# already exists then synchronise the installed packages with those listed
# in requirements.txt. The list of packages will be updated if requirements.in
# changes.

.PHONY: clean-venv
clean-venv:
	rm -rf $(venv_dir)

$(venv_dir):
	$(python) -m venv $(venv_dir)
	$(pip) install --upgrade pip setuptools wheel
	$(pip) install pip-tools

requirements.txt: requirements.in
	@echo "Pin the list of dependencies for development..."
	$(pip-compile) requirements.in

.PHONY: requirements
requirements: requirements.txt
	@echo "Pin the list of dependencies for any requirements file that changed ..."

.PHONY: venv
venv: $(venv_dir) requirements
	$(pip-sync) requirements.txt

# ##########
#   Checks
# ##########

.PHONY: lint
lint:
	@echo "Run ansible-lint on the playbook..."
	$(ansible-lint) playbook.yml

# #########
#   Tests
# #########

.PHONY: tests
tests:
	@echo "Run all the tests..."
	$(molecule) test

# ##############
#   Deployment
# ##############

.PHONY: provision
provision:
	@echo "Provision a new server..."
	$(ansible-playbook) -i $(inventory) $(playbook)

.PHONY: update
update:
	@echo "Update the app..."
	$(ansible-playbook) -i $(inventory) $(playbook) --tags=deploy
