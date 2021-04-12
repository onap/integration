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


Wrapper for simulators
......................

1. In order to deploy the Helm release with a simulator, place a YAML file
describing the Helm release in src/onaptests/templates/helm_charts.

  The structure of the YAML file should be like in the example below.
  Dependencies contain all the charts that need to be pulled.

  .. code-block:: YAML

    # Helm release information
    api_version:       # API_VERSION
    app_version:       # APP_VERSION
    chart_name:        # SIMULATOR_NAME
    version:           # CHART_VERSION

    # Helm charts that need to be pulled
    dependencies:
    - name:            # SIMULATOR_NAME
      version:         # CHART_VERSION
      repository:      # URL
      local_repo_name: # REPO_NAME

2. Install the Helm release:

  .. code-block:: Python

     from onaptests.steps.wrapper.helm_charts import HelmChartStep

     chart = HelmChartStep(
         cleanup         = BOOLEAN,
         chart_info_file = YAML_FILE_NAME  # name, not the path
     )
     chart.execute()

3. Start the simulator via an API call:

  .. code-block:: Python

     start = SimulatorStartStep(
         cleanup   = BOOLEAN,
         https     = BOOLEAN,
         host      = HOSTNAME,
         port      = PORT,
         endpoint  = START_ENDPOINT,  # if applicable
         method    = REQUEST_METHOD,  # GET, POST etc.
         data      = PAYLOAD  # {"json": {...}, ...}
    )
    start.execute()

4. Undeploy the Helm release:

  .. code-block:: Python

     chart.cleanup()
