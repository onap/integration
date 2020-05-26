.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_pnf_onboarding_preonboarding:

5G - PNF Pre-Onboarding & Onboarding
----------------------

Description
~~~~~~~~~~~

Use case introduces possibility of pre-onboarding and onboarding a vendor PNF onboarding package in ONAP for 5G and other use cases.
`Detailed 5G - PNF Pre-Onboarding & Onboarding use case documentation <https://wiki.onap.org/pages/viewpage.action?pageId=45303641>`_
PNF CSAR Package that is onboarded as Vendor Software Package to SDC must meet the following requirements:  `VNF or PNF CSAR Package Requirements <https://docs.onap.org/en/frankfurt/submodules/vnfrqts/requirements.git/docs/Chapter5/Tosca/ONAP%20VNF%20or%20PNF%20CSAR%20Package.html>`_
Before SDC Onboarding, PNF onboarding package/archive can be verified using VNF SDK tools.


How to Use
~~~~~~~~~~
- PNF pre-onboarding (VNF SDK verification)
  The pre-onboarding step is optional and it can be used to verify a vendor PNF onboarding package/archive format by VNF SDK tools
  `VNF SDK Tools Documentation <https://docs.onap.org/en/frankfurt/submodules/vnfsdk/model.git/docs/index.html>`_
  `VNF SDK Test Cases <https://wiki.onap.org/pages/viewpage.action?pageId=58231094>`_

- PNF onboarding (SDC Resource Onboarding)
  The onboarding step is mandatory in ONAP.
  A vendor-provided PNF onboarding package must be onboarded according to procedure: `SDC Resource Onboarding <https://docs.onap.org/en/frankfurt/guides/onap-user/design/resource-onboarding/index.html>`_


