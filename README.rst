==================
Ansible Virtualenv
==================
This template contains an ansible playbook for deploying a Django-based
app server running a Debian-based operating system, to either a staging
or production environment running on a Virtual Private Server or a Dedicated
Server. The project uses a virtualenv for running Django and Celery so the
application is completely isolated from the system python.

This template is intended to be used with Django sites created using the
`django-project-template`_. It should be easily changed to suit any Django
project. Only the environment variables used to configure Django should
need changing.

.. _django-project-template: https://github.com/StuartMacKay/django-project-template

Project Layout
--------------
::

    .
    ├── .envrc
    ├── group_vars
    │   ├─── appserver
    │   │    └── vars.yml
    │   ├─── staging
    │   │    ├── vars.yml
    │   │    └── vault.yml
    │   └─── production
    │        ├── vars.yml
    │        └── vault.yml
    ├── inventories
    │   └── single.yml
    ├── keys
    │   ├── id_rsa-project
    │   └── id_rsa-project.pub
    ├── molecule
    │   └── default
    ├── roles
    │   ├── app
    │   ├── base
    │   ├── celery
    │   ├── certbot
    │   ├── ...
    │   └── users
    ├── playbook.yml
    └── requirements.txt

``group_vars`` contains the variable definitions for deploying appservers to
staging and production environments. Each environment has the sensitive
variables stored in a vault. The password for each vault is 'password'. You
MUST at least change the password for production.

``inventories`` contains sample inventories for deploying to different server
configurations. ``single.yml`` is the only example included right now and if
for deploying the application, database, and message broker to a single server.

``keys`` contains a sample SSH key which can be added to your key chain, using
``ssh-add`` to get start with deployments to a development server. It is also
used to test the playbook. The public key is used in the environment variables
for creating a user account for the deployment and for managing the server.
Since this key is in a public repository it is insecure by default. You MUST
replace this with a secure key for your production deployments.

``molecule`` contains all the files used to test the playbook using Docker.
The tests using the django-watchman end-point to verify the status of the
database, storage and cache backends. This will not cover everything but it
is a good test of whether Django is functioning.

``roles`` are organised by feature and contain everything needed to deploy
the app server. Within each role the tasks are organised with separate files
for each step. The intention is to make the playbook modular and so easy to
comprehend and easy to refactor and add new features. This means there is
probably more yaml than is healthy but you will find that things are easy
to find and it's easy to throw away the stuff you don't want. There are
separate tasks for each operating system, for example, when installing
native packages. The variables for role define sensible defaults for each
task. You can override these as needed, in the group_vars.

``playbook.yml`` simply runs through all the roles to install everything
needed for the app server. It is opinionated. It assumes there are two
environments, staging and production, which can be deployed. For local
development this is probably sufficient. For large production systems this
is really only a starting point. Any medium or large-scale system will be
deployed across multiple servers, with load balancing, database failover,
etc.

``requirements.txt`` contains all the packages to run anisble and molecule
from a virtual environment. There is also an direnv configuration file,
``.envrc`` so you can activate the virtualenv automatically whenever you
``cd`` to the directory.

Variables
---------
Variables can be defined at many levels in a playbook, each with different
priorities. This project tries to keep things simple, easy to understand,
and so stay sane. There are three levels:

1. Role variables, which provide sensible defaults for configuring a service.
   For example, roles/postgresql/defaults/main.yml

2. Group variables, which define the environment for servers, either by the
   role they play, e.g. appserver, or the environment, e.g. production.

3. Finally there are deployment variables, which define how the application
   is deployed - which service is deployed where.

Role variables provide the basic definitions, which are then overridden by group
variables, which in turn are overridden by deployment variables. Ansible's variable
precedence rules are much more complex than this, but this provides a simple,
well-organised, easy to work with, easy to manage, model.

A number of variables, e.g. ``app_repository`` are set to ``!!null`. You need
to set these (obviously) according to your application's needs.

Django Layout
-------------
::

    <project>
       ├── .env
       ├── .venv/
       ├── manage.py
       ├── requirements.txt
       ├── <project>
       │   ├─── gunicorn.py
       │   ├─── settings.py
       │   └─── wsgi.py
       ├── media/
       ├── static/
       ...

The playbook tasks assume the typical layout for a Django project. <project>
is the name of your site, and the root directory of the checked out repository.
The config files: settings.py etc are in a sub-folder with the same name. The
virtual environment for the application is in the .venv folder. A dotenv file
is used to set the environment variables for django or celery.

If you're project is different, for example, if you follow the Two Scoops layout,
you can set the following variables:

.. code-block:: yaml

    # The dependencies required to run the app
    python_requirements_file: "{{ app_root_dir }}/requirements.txt"

    # The wsgi settings module
    gunicorn_settings_module: "config.wsgi"
    # The configuration file for gunicorn
    gunicorn_configuration_file: "{{ app_root_dir }}/config/gunicorn.py"

    # The django settings module
    django_settings_module: "config.settings"

Security
--------
Both the staging and production group variables are stored in vaults.
The password for each is 'password'. Keep the same password for staging
but you MUST change the password for production. Also make sure you change
the secret key for Django. The same value is used in both and besides they
are public knowledge.

In addition to the vaults for storing all sensitive information, ansible is
configured so you never stored passwords, unprotected in files. The config
file, ``ansible.cfg`` sets ``ask_vault_pass`` and ``become_ask_pass`` so you
will always be prompted when doing a deployment. This is done even for
staging, so healthy habits are reinforced.

Getting Started
---------------
Check out the repository:

..  code-block:: shell

    git clone git@github.com:StuartMacKay/django-ansible-template.git deploy

Next, create the virtualenv and install the requirements:

..  code-block:: shell

    cd deploy
    make venv

Use direnv to automatically activate the virtualenv when you cd to the
playbook directory:

..  code-block:: shell

    direnv allow .

Create an inventory from the example in the ``deploy`` directory:

.. code-block:: shell

   cp inventory.example staging

Next edit the inventory to set the IP address of a local virtual machine:

.. code-block:: ini

    [appserver]
    192.168.10.22

    [staging]
    192.168.10.22

The ``app_domain_name`` only needs to be defined for production deployments.
All the other variables in ``group_vars`` have sensible defaults so you can
do a deployment immediately.

Deployments
-----------
When a Virtual Machine or Virtual Private Server (VPS) is created there are
three scenarios which determine how the machine is can be accessed:

#. authenticate with username / password (root)
#. authenticate with ssh key (root)
#. authenticate with username / password (set during install) + sudo

The command to run an initial deployment has different variations to provision
the machine:

1. authenticate with username / password (root)

..  code-block:: shell

    ansible-playbook -i staging playbook.yml -u root --ask-pass

2. authenticate with ssh key (root)

   Copy the private key to your ``.ssh`` directory. Make sure you don't overwrite
   existing keys with the same name. The add the key to your key-chain using ``ssh-add``.
   Now run the playbook:

..  code-block:: shell

    ansible-playbook -i staging playbook.yml -u root

3. authenticate with username / password

   This is the same as the first scenario. Only the username has changed:

..  code-block:: shell

    ansible-playbook -i staging playbook.yml -u <username> --ask-pass

    The ansible configuration file, ``ansible.cfg`` has the ``become_ask_pass``
    option set to ``true`` so you will be prompted to enter the password in order
    to become the root user, via ``sudo``.

The initial deployment locks down access to the server. You can only login using
an authorized key; root login is disabled; logins can only be by admins (listed
in the staging or production group_vars files) and a password is required for
sudo access.

Subsequent deployments are now run using:

..  code-block:: shell

    ansible-playbook -i staging playbook.yml

assuming the your username on the ansible control node (i.e. the local machine)
matches one of the admin accounts added to the server. Otherwise you will have
to pass the username to login as using ``-u``.

Each of the roles have tags so you can run each role independently. If you
run a local virtual machine you can use this to verify each role is working:

..  code-block:: shell

    ansible-playbook -i staging playbook.yml --tags="memcached"

The roles often have tags for each group of tasks so you can test each
step separately:

..  code-block:: shell

    ansible-playbook -i staging playbook.yml --tags="memcached.install"

Testing
-------
The playbook is tested with ``molecule`` using the Docker driver - you will
need to have the Docker Engine installed. The test creates the containers
(one for each operating system supported - currently only Ubuntu 22.04 LTS),
provisions them and verifies everything is working using the ``django-watchman``
end-point which reports the status of the database, storage and cache backends.

..  code-block:: shell

    molecule test

Molecule runs through a series of steps (playbooks) for the life-cycle of a test.
You can execute these steps individually when testing whether a role is working:

..  code-block:: shell

    molecule create
    molecule converge
    molecule verify

The ``create`` step leaves the containers running so you can run ``converge``
step multiple times as you make adjustments to your roles to check that the
deployment is working. ``verify`` then calls the end-point and compares the
json data returned to confirm the backend are ok. Once you are finished you
can shut everything down and delete the containers using:

..  code-block:: shell

    molecule destroy

The setup for the molecule tests in ``molecule/default/create.yml`` uses a
mount point to map the ssh-agent socket to ``/ssh-agent`` in the container,
and sets the ``SSH_AUTH_SOCK`` environment variable to the location. You
can then add your github private key to your keychain using ``ssh-add`` to
check out code from a private repository.

.. _issues: https://github.com/StuartMacKay/django-project-templates/issues

Acknowledgements
----------------
This playbook is based on the extremely useful `ansible-django-stack`_
which has been used extensively across many personal projects.

.. _ansible-django-stack: https://github.com/jcalazan/ansible-django-stack
