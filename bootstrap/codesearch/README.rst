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
