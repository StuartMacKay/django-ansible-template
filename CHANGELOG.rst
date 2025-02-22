=========
Changelog
=========

Unreleased
----------
* Add a dotenv file for configuring Django settings.

* Separate configuring gunicorn into a role.

* Reorganised RabbitMQ variables and tasks to decouple it from the Django role.

* Reorganised postgreSQL variables and tasks to decouple it from the Django role.

* Replace the fail2ban configuration files, based on server groups, with a
  single variable, fail2ban_enabled.

0.0.1 (2024-01-05)
------------------
* Initial release, adding everything to deploy an app to a local virtual machine
  or to a remote Virtual Private Server.
