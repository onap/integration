.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-tooling:

.. _integration-simulators:

Simulators
==========

Simulators are regularly created for use cases. The goal of this section is to:

- Highlight the existing Simulators
- Provide recommendations when starting developing a new simulator

.. important::
    Before developing a new simulator, check that it does not exist...and
    refactor/contribute to existing simulators rather than recreating new ones.


Existing simulators
-------------------

.. csv-table:: Simulators
  :file: ./files/csv/simulators.csv
  :widths: 10,50,20,20
  :delim: ;
  :header-rows: 1


Recommendations
---------------

The simulator code
..................

We recommend to create a dedicated repository (ask Integration team).

.. csv-table:: Simulator repositories
    :file: ./files/csv/repo-simulators.csv
    :widths: 30,50,20
    :delim: ;
    :header-rows: 1


Dockerization
.............

From this repository, create a jenkins job to automatically build the dockers.

Helm Chart
..........

It is recommended to create a helm chart in order to run the simulators.


Start your simulator from pythonsdk
...................................

TODO
