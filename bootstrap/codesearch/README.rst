============================================
 ONAP Integration > Bootstrap > Code search
============================================

This directory contains a set of Vagrant scripts that will automatically set up a Hound_ instance
with config generator to index all ONAP code.

This is intended to show a beginning ONAP developer how to set up and configure an environment that
allows to search through ONAP code repositories quickly. It is not intended to be used as
a production code search solution.

`Upstream Docker image` has not been used due to lack of project activity. This environment
(together with daemon configuration generator) might be migrated to a new Docker image recipe in
future, though.

.. _Hound: https://github.com/hound-search/hound
.. _`Upstream Docker image`: https://hub.docker.com/r/etsy/hound


Prerequisites
-------------

Virtualisation provider
~~~~~~~~~~~~~~~~~~~~~~~

Provided vagrantfile is generic enough that it should work with any Vagrant provider.
It has been tested using default VirtualBox provider and also libvirt_ provider with vagrant-libvirt_ plugin.
Plugin documentation provides detailed `installation instructions`_ that will guide through the process.

.. note::
   Remember to uncomment `deb-src` repositories for `apt-get build-dep` step on Debian/Ubuntu.

.. _libvirt: https://libvirt.org
.. _vagrant-libvirt: https://github.com/vagrant-libvirt/vagrant-libvirt
.. _`installation instructions`: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

Virtual machine manager
~~~~~~~~~~~~~~~~~~~~~~~

Environment has been tested using latest Vagrant_ as of writing this documentation (`v2.2.16`_). Some
features (e.g. triggers_) might not be supported on older versions.

.. _Vagrant: https://www.vagrantup.com/downloads.html
.. _`v2.2.16`: https://github.com/hashicorp/vagrant/blob/v2.2.16/CHANGELOG.md
.. _triggers: https://www.vagrantup.com/docs/triggers/


Running
-------

If using vagrant-libvirt provider additional `--provider` flag or setting `VAGRANT_DEFAULT_PROVIDER` environmental
variable might be required in case there are multiple providers available.

.. note::
   One of the following commands should be executed depending on the provider you'd like to use. Run it within the
   directory where `Vagrantfile` is stored (`integration/bootstrap/codesearch`).

.. code-block:: sh

   vagrant up --provider=libvirt # to leverage vagrant-libvirt provider
   vagrant up # to leverage default VirtualBox provider

This will:

#. Start and prepare virtual machine
#. Generate configuration files
#. Run Hound instance as a tmux_ session named `codesearch`

At any time you can reload or stop and later start the box, it's set up to automatically run the hound process.

.. _tmux: https://github.com/tmux/tmux/wiki


Usage
-----

Once ready (cloning repositories and building index might initially take some time) code search will
be available at http://localhost:6080
