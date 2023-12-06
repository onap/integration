.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-CICD:

.. integration_main-doc:

CI/CD
=====

.. important::
   Integration team deals with 2 different CI/CD systems.

  - Jenkins CI/CD, CI managed by LF IT and CD by Integration team
  - GitLab-CI managed by Integration team

Continuous Integration
----------------------

The CI part provides the following features:

- Repository verification (format of the INFO.yaml)
- Patchset verification thanks to json/yaml/python/go/rst/md linters. These Jenkins
  verification jobs are hosted in the ci-management repository. They can vote
  +1/-1 on patchset submission. Integration team systematically enables linters
  on any new repository
- Docker build: Integration team builds testsuite dockers and xtesting dockers.
  These dockers are built then pushed to Nexus through a jjb also hosted in the
  ci-management repository.

The different verification chains are defined in https://jenkins.onap.org/:

- CSIT: https://jenkins.onap.org/view/CSIT/
- testsuite: https://jenkins.onap.org/view/testsuite/
- integration: https://jenkins.onap.org/view/integration/
- testsuite-robot-utils: https://jenkins.onap.org/view/testsuite-robot-utils/

The Jenkins jobs (jjb) are hosted in https://git.onap.org/ci-management/.

Continuous Deployment
---------------------

GitLab CD
.........

This CD is leveraging public gitlab-ci mechanism and used to deploy several ONAP
labs:

- Daily Master: daily run using OOM Master
- Weekly Master: run once a week with longer tests
- Gating: run on OOM, clamp or SO patchset submission. It means a full ONAP
  deployment on demand based on new patchset declared in gerrit.

See :ref:`Integration CI guideline  <integration-ci>` for details.
