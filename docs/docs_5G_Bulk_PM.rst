.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_bulk_pm:

5G Bulk PM
----------

5G Bulk PM Package
~~~~~~~~~~~~~~~~~~
- 5G Bulk PM Package: https://wiki.onap.org/pages/viewpage.action?pageId=38121543

Description
~~~~~~~~~~~
The Bulk PM feature consists of an event-driven bulk transfer of monitoring data from an xNF to ONAP/DCAE. A micro-service will listen for 'FileReady' VES events sent from an xNF via the VES collector. Once files become available the collector micro-service will fetch them using protocol such as FTPES (committed) or SFTP. The collected data files are published internally on a DMaaP Data Router (DR) feed.
The ONAP 5G Bulk PM Use Case Wiki Page can be found here:
https://wiki.onap.org/display/DW/5G+-+Bulk+PM

How to Use
~~~~~~~~~~
See the following instructions on how to manually test the feature. https://wiki.onap.org/display/DW/5G+Bulk+PM+Usecase+Testing+\@+Ericsson+Lab+-+Casablanca
The tests can also be executed using the Robot framework, information can be found https://wiki.onap.org/pages/viewpage.action?pageId=38121543

Test Status and Plans
~~~~~~~~~~~~~~~~~~~~~
To see information on the status of the test see https://wiki.onap.org/display/DW/5G+-+Bulk+PM+-+Test+Status

Known Issues and Resolutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
none.
