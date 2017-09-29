=================================================
Example usage to bring up a developer environment
=================================================

In the example, we will bring up a single ONAP component using the Vagrant ONAP
tool.

There are multiple scenarios in which this tool can be made use of by a
developer, they usually fall in the following use cases.

Use case 1: Use Vagrant ONAP to just clone project related source code
----------------------------------------------------------------------

In this use case, the developer needs just the source code of the project to work on.

Since the Vagrant ONAP project supports building docker containers and compiling
source files, we need to first edit the settings.yaml file to add key value pairs
indicating we need to only clone repo and not build docker image or compile then.
By default, Vagrant ONAP clones repo, but to not run the build process and cloning
docker images, the following are required to be added in the settings file.

.. code-block:: console

    skip_get_images: "True"

.. end

The reason this is done is because as mentioned in the
`configure execution docs. <https://git.onap.org/integration/tree/bootstrap/vagrant-onap/doc/source/features/configure_execution.rst>`,
the default values taken are:

.. code-block:: console

    'build_image'         => 'True',
    'clone_repo'          => 'True',
    'compile_repo'        => 'False',
    'enable_oparent'      => 'True',
    'skip_get_images'     => 'False',
    'skip_install'        => 'True'

.. end

We override them and skip_get_images is given precedence over build_image.

Use case 2: Use Vagrant ONAP to clone project related source code and clone Docker Images
-----------------------------------------------------------------------------------------

In this use case, the developer needs to clone docker images of the project to work on.

For this case, we will edit the settings.yaml file to add key value pairs indicating we
need to clone repo and clone docker image from Nexus.

.. code-block:: console

    build_images: "False"
    compile_repo: "True"
    skip_get_images: "False"
    skip_install: "True"

.. end

Use case 3: Use Vagrant ONAP to clone project related source code and build Docker Images locally
-------------------------------------------------------------------------------------------------

In this use case, the developer needs to build docker images of the project to work on.

For this case, we will edit the settings.yaml file to add key value pairs indicating we need to
clone repo and build docker image locally and not fetch them from Nexus.

.. code-block:: console

    build_images: "True"
    compile_repo: "True"
    skip_get_images: "False"
    skip_install: "True"

.. end

Use case 4: Use Vagrant ONAP to clone project related source code and build Docker Images and start services
------------------------------------------------------------------------------------------------------------

In this use case, the developer needs to build docker images of the project he or
she wanted to work on and start the services running inside them.

For this case, we will edit the settings.yaml file to add key value pairs indicating
we need to clone repo, compile repo, build docker image and run the image.

.. code-block:: console

    build_images: "True"
    compile_repo: "True"
    skip_get_images: "False"
    skip_install: "False"

.. end

Once the required changes to the settings file is added, we can use the run.sh
script in tools directory to setup the development environment.

Example steps for setting up a development environment for VFC project.
-----------------------------------------------------------------------

In this example we will be using vagrant ONAP to get all the source code of VFC
project and the developer can point the IDE to the cloned repo in the ./opt directory
and start the development process.

.. code-block:: console

   $ ./tools/run.sh vfc

.. end

At the end of the setup process, all the VFC related source code will be present
in the vagrant-onap/opt/ directory. The developer can point an IDE to this directory
and start contributing. When the changes are done, the developer can SSH into the VM
running VFC and tests can be executed by running Maven for Java and Tox for Python
from the ~/opt/vfc directory.

.. code-block:: console

   $ vagrant ssh vfc
   $ cd ~/opt/vfc/<vfc-subrepo>
   $ tox -e py27

.. end

This way the tool helps the developer to clone repos of a particular project,
without having to manually search for repos and setup an environment.

Also, if something gets messed up in the VM, the developer can tear down the VM
and spin a fresh one without having to lose the changes made to the source code since
the ./opt files are in sync from the host to the VM.

.. code-block:: console

   $ vagrant destroy vfc

.. end