=========
Changelog
=========

0.0.2 (2025-02-22)
------------------
* Add a handler to reload nginx after enabling the site.

* Set the USER variable in the gunicorn process environment, otherwise it cannot
  read the .env file.

* Update README to handle different Django project layouts.

* Update README to describe how the variables are organised.

* Renamed 'development' group_vars to 'staging'.

* Delete the app_front_dir variable, it is specific to the project layout.

* Delete the app_backend_dir variable, it is specific to the project layout.

* Upgrade to python 3.12 for the virtualenv.

* Reorganise handlers for restarting services.

* Decouple tasks for configuring nginx from the Django role.

* Delete the django_watchman_tokens variable, it is specific to an app.

* Deleted the django_debug variable, it is specific to an app.

* Deleted the env_name variable, it is specific to an app.

* Add task to memcached after the Django app is deployed.

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
