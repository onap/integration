=======================
Modify execution values
=======================

In order to provide a flexible platform that adjusts to different developer
needs, there are two mechanisms to configure the execution of this project.

Settings configuration file
---------------------------

The first mechanism refers to the process to replace default configuration
values in the settings configuration file. This file needs to be placed into
the *./etc* folder and named *settings.yaml*. It must contain the key/pair
configuration values that will be overriden.

.. note::

    There are sample files (e. g. settings.yaml.development and
    settings.yaml.testing) placed into the *./etc* folder. Their purpose is to
    provide a reference of different configurations.

.. end

Configuration values:

+------------------+-------------------+---------------------------------------+
| Key              | Values            | Description                           |
+==================+===================+=======================================+
| build_image      | "True" or "False" | Determines if the Docker image is     |
|                  |                   | retrieved from public hub or built    |
|                  |                   | from source code.                     |
+------------------+-------------------+---------------------------------------+
| clone_repo       | "True" or "False" | Determines if all the source code     |
|                  |                   | repositories of a given component are |
|                  |                   | cloned locally.                       |
+------------------+-------------------+---------------------------------------+
| compile_repo     | "True" or "False" | Determines if all the source code     |
|                  |                   | repositories of a given component are |
|                  |                   | going to be compiled.                 |
+------------------+-------------------+---------------------------------------+
| enable_oparent   | "True" or "False" | Determines if the OParent project     |
|                  |                   | will be used during the maven         |
|                  |                   | compilation.                          |
+------------------+-------------------+---------------------------------------+
| skip_get_images  | "True" or "False" | Determines if the process to build or |
|                  |                   | retrieve docker images of a given     |
|                  |                   | component are going to skipped.       |
+------------------+-------------------+---------------------------------------+
| skip_install     | "True" or "False" | Determines if the process to start    |
|                  |                   | the services of a given component     |
|                  |                   | will be started.                      |
+------------------+-------------------+---------------------------------------+

Parameters
----------

The **skip_get_images** and **skip_install** are the only two configuration
values that can be overriden using *-g* and *-i* respectively by the run scripts
(*./tools/run.sh* and *.\\tools\\Run.ps1*).

.. note::

    The script parameters take precendence of the configuration file.

.. end

.. code-block:: console

   $ ./tools/run.sh sdc -g

.. end

