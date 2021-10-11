.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-CICD:

.. integration_main-doc:

CI/CD
=====

.. important::
   Integration team deals with 2 different CI/CD systems.

  - Jenkins CI/CD, CI managed by LF IT and CD by Integration team
  - GitLab-ci managed by Integration and OOM team

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
- integration-terragrunt: https://jenkins.onap.org/view/integration-terragrunt/
- testsuite-robot-utils: https://jenkins.onap.org/view/testsuite-robot-utils/

The Jenkins jobs (jjb) are hosted in https://git.onap.org/ci-management/.

Continuous Deployment
---------------------

There are 2 Continuous Deployment architectures.

Jenkins CD on Windriver/Intel lab
..................................

The CD part on Windriver/Intel is based on Jenkins.

It is based on a standalone VM hosting a Jenkins server.
The credentials of this VM as well as the Jenkins server have been provided to
integration committers.

Several jobs can be triggered from this Jenkins interface.
Historically several chains were run daily (staging/release) but due to
performance issues, they have all been stopped.
Only SB-00 has been kept for use case support.
The Jenkins interface was however used to launch the installation of SB-00.

This Jenkins script is leveraging resources available in OOM and integration
repositories.

The replacement of this CD by a GitLab runner based CD to unify the CD
management was planned, but finalizing the operation in Guilin was not possible
due to performance issues.

GitLab CD
.........

This CD is leveraging public gitlab-ci mechanism and used to deploy several ONAP
labs:

- Daily Master: daily run using OOM Master
- Daily Guilin: daily run using the last stable version during Honolulu Release
  processing
- Daily Honolulu: daily run setup at RC0 (candidate dockers available for integration)
- Daily Istanbul: daily run setup at RC0 (candidate dockers available for integration)
- Weekly Master: run once a week with longer tests
- Weekly Istanbul: run once a week with longer tests
- Gating: run on OOM, clamp or SO patchset submission. It means a full ONAP
  deployment on demand based on new patchset declared in gerrit.

See :ref:`Integration CI guideline  <integration-ci>` for details.
