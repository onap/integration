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

Environment has been tested using libvirt_ provider with vagrant-libvirt_ plugin. Plugin
documentation provides detailed `installation instructions`_ that will guide through the process.

.. note::
   Remember to uncomment `deb-src` repositories for `apt-get build-dep` step on Debian/Ubuntu.

.. _libvirt: https://libvirt.org
.. _vagrant-libvirt: https://github.com/vagrant-libvirt/vagrant-libvirt
.. _`installation instructions`: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

Virtual machine manager
~~~~~~~~~~~~~~~~~~~~~~~

Environment has been tested using latest Vagrant_ as of writing this documentation (`v2.2.6`_). Some
features (e.g. triggers_) might not be supported on older versions.

.. _Vagrant: https://www.vagrantup.com/downloads.html
.. _`v2.2.6`: https://github.com/hashicorp/vagrant/blob/v2.2.6/CHANGELOG.md#226-october-14-2019
.. _triggers: https://www.vagrantup.com/docs/triggers/


Running
-------

Additional `--provider` flag or setting `VAGRANT_DEFAULT_PROVIDER` environmental variable might be
useful in case there are multiple providers available.

.. note::
   Following command should be executed within the directory where `Vagrantfile` is stored
   (`integration/bootstrap/codesearch`).

.. code-block:: sh

   vagrant up --provider=libvirt

This will:

#. Start and prepare virtual machine
#. Generate required authorization and configuration files
#. Run Hound instance as a tmux_ session named `codesearch`

.. _tmux: https://github.com/tmux/tmux/wiki


Usage
-----

Once ready (cloning repositories and building index might initially take some time) code search will
be available at http://localhost:6080
