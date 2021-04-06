.. This work is licensed under a
   Creative Commons Attribution 4.0 International License.
.. integration-labs:

.. integration_main-doc:

Integration Labs
================

.. important::
   The Integration team deals with several community labs:

   - The Windriver/Intel lab
   - The Azure staging lab
   - The Orange openlab
   - The DT lab
   - The Nokia dualstack lab

Additionally integration contributors may deal with their own lab pushing results
in the integration portal (See DT http://testresults.opnfv.org/onap-integration/dt/dt.html)

Windriver/Intel lab
-------------------

The Historical Community Lab
............................

This lab is the historical lab of ONAP integration team based on Openstack Ocata.
During Guilin, it has been audited and performance issues have been reported
(RAM and CPU).
A reinstallation has to be planned.

The figure hereafter shows all the ONAP project consuming Windriver/Intel lab
resources (April 2020).

.. figure:: files/windriver/windriver_servers.png
   :align: center

In order to avoid disturbing the projects, the reinstallation has been postponed
after Guilin.
A huge cleanup has been done in order to save the resources.
The historical CI/CD chains based on a stand-alone Jenkins VM hosted in Windriver
have been stopped. For Guilin only SB-00 has been kept and re-installed for the
use case support.

If you want to use this lab, you need a VPN access. The procedure is described in
the `wiki <https://wiki.onap.org/pages/viewpage.action?pageId=29787070>`_.

Environment Installation Scripts
................................

In addition to the official OOM scripts, Integration used to provide some
extra scripts/guidelines to install your OpenStack infrastructure thanks to a
heat template. See :ref:`Integration heat guideline <integration-installation>`
for details. These scripts were used mainly in Windriver labs but are not actively
maintained.

.. caution:
   The official reference for installation is the OOM documentation.

Azure staging lab
-----------------

An additional Azure staging lab has been created for Guilin. It is installed as
any daily/weekly/gating labs (see CI/CD sections).
Contact the Integration team to get an access.

Orange Openlab
--------------

This lab is for community use. It is always provided with the last stable version,
i.e. Frankfurt release during Guilin development time.
Please note that such labs do not provide admin rights and is shared with all
the users. It can be used to discover ONAP.

See `Orange Openlab access procedure <https://wiki.onap.org/display/DW/Orange+OpenLab>`_
for details.

DT lab
------

The DT lab reported Master daily results in addition of guilin daily results.

Nokia lab
---------

Nokia setup a lab to support the dual stack IPv4/IPv6 tests. Results are shared
with the community in
`<https://logs.onap.org/onap-integration/daily/onap_daily_nokia_dualstack_master/>`_
