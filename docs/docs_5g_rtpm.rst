.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_realtime_pm:

5G - Real Time PM and High Stream Data Collection
-------------------------------------------------

Source files
~~~~~~~~~~~~

- Optional in case you want to use the xNF simulator: https://git.onap.org/integration/tree/test/mocks/hvvessimulator/hvves_sim.yaml

Description
~~~~~~~~~~~

The Real-Time Performance Measurements support allows for a PNF to send streaming performance measurements to ONAP. It develops the capability for the PNF/VNF to send a subset of the typical performance measurement data to ONAP. The data can be sent to ONAP more rapidly than for bulk PM, on the order of seconds. This is valuable to the service provider and operators to debug problems and assess the impact of configuration changes. It uses an VES event driven system for high volume data delivery from xNF to ONAP/DCAE.  A new VES-HV (High Volume) Collector supports GPB over TLS/TCP. The xNF generates hvMeas events containing real time PM data.  These events will be GPB encoded and transmitted over TLS/TCP. Collected events are published to DMaaP and sent directly to the Kafka Cluster (bypassing the DMaaP-MR layer).

Component and API descriptions can be found under:

- `High Volume VNF Event Streaming (HV-VES) Collector <https://onap.readthedocs.io/en/latest/submodules/dcaegen2.git/docs/sections/services/ves-hv/index.html>`_
- `HV-VES (High Volume VES) <https://onap.readthedocs.io/en/latest/submodules/dcaegen2.git/docs/sections/apis/ves-hv/index.html#hv-ves-high-volume-ves>`_

How to verify
~~~~~~~~~~~~~

Follow instructions in the links below to send data to HV-VES collector and verify messages published on Kafka topic:

- `HV-VES xNF simulator integration to ONAP <https://wiki.onap.org/display/DW/HV-VES+simulator>`_ (HVVESsimulator-HV-VESxNFmessagesimulationfromshell)
- `HV-VES xNF message simulation from shell <https://wiki.onap.org/display/DW/HV-VES+simulator>`_ (HV-VESsimulator-HV-VESxNFsimulatorintegrationtoONAP)

Useful links
~~~~~~~~~~~~

- `5G - Real Time PM and High Volume Stream Data Collection <https://wiki.onap.org/display/DW/5G+-+Real+Time+PM+and+High+Volume+Stream+Data+Collection>`_
- `5G - Real Time PM and High Volume Stream Data Collection - Integration Test Cases <https://wiki.onap.org/display/DW/5G+-+Real+Time+PM+and+High+Volume+Stream+Data+Collection+-+Integration+Test+Cases>`_
