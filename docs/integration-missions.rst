.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. _integration-missions:

Integration missions
====================

.. important::
   The Integration project is in charge of:

   - Providing testing environment
   - Supporting the use case teams
   - Managing ONAP CI/CD chains
   - Developing tests
   - Providing baseline images
   - Validating the ONAP releases

The different activities may be summarized as follows (proportions are indicative):

.. figure:: files/integration-project.png


For each release, the integration team provides the following artifacts:

- A daily CI chain corresponding to the release
- Staging labs to perform the pairwise testing (when not automated) and support
  the use case teams
- Baseline JAVA and Python images
- oparent library to manage Java dependencies
- Test suites and tools to check the various ONAP components
- Use-case documentation and artifacts
- A testsuite docker included in the ONAP cluster to execute the robot based tests
- Configuration files (scripts, Heat templates, csa files) to help installing
  and testing ONAP
- Wiki release follow-up tables (blocking points, docker versions,...)

Please see the `integration wiki page <https://wiki.onap.org/display/DW/Integration+Project>`_
for details.