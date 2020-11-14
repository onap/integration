.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-CICD:

.. integration_main-doc:

CI/CD
=====

.. important::
   Integration team deals with 2 different CI/CD systems.

  - jenkins CI/CD, CI managed by LF IT and CD by Integration team
  - gitlab-ci managed by Integration and OOM team

Continuous Integration
----------------------

The CI part provides the following features:

- Repository Verification (format of the INFO.yaml)
- Patchset verification thank to json/yaml/python/go/rst/md linters. These jenkins
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
- integration-terragrunt: https://jenkins.onap.org/view/integration-terragrunt/
- testsuite-robot-utils: https://jenkins.onap.org/view/testsuite-robot-utils/

The jenkins jobs (jjb) are hosted in https://git.onap.org/ci-management/.

Continuous Deployment
---------------------

There are 2 Continuous Deployment architectures.

Jenkins CD on Windriver/Intel lab
..................................

The CD part on windriver/Intel is based on jenkins.

It is based on a standalone VM hosting a jenkins server.
The credentials of this VM as well as the jenkins server have been provided to
integration committers.

Several jobs can be triggered from this jenkins interface.
Historically several chains were run daily (staging/release) but due to
performance issues, they have all been stopped.
Only SB-00 has been kept for use case support.
The jenkins interface was however used to launch the installation of SB-00.

This jenkins script is leveraging resources available in OOM and integration
repositories.

It was planned to replaced this CD by a gitlab runner based CD to unify the CD
management. But due to performance issue in the DC it was not possible to
finalize the operation in Guilin.

Gitlab CD
.........

This CD is leveraging public gitlab-ci mechanism and used to deploy several ONAP
labs:

- Daily Master: daily run using OOM Master
- Daily Frankfurt: daily run using the last stable version during Guilin Release
  processing
- Daily Guilin: daily run setup at RC0 (candidate dockers available for integration)
- Weekly Master: run once a week with longer tests
- Gating: run on OOM, clamp or SO patchset submission. It means a full ONAP
  deployment on demand based on new patchset declared in gerrit.

See :ref:`Integration CI guideline  <integration-ci>` for details.
