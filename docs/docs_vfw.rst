.. _docs_vfw:

vFirewall Use Case
------------------

Source files
~~~~~~~~~~~~

- vFirewall/vSink template file: https://git.onap.org/demo/plain/heat/vFWCL/vFWSNK/base_vfw.yaml
- vFirewall/vSink environment file: https://git.onap.org/demo/plain/heat/vFWCL/vFWSNK/base_vfw.env

- vPacketGenerator template file: https://git.onap.org/demo/plain/heat/vFWCL/vPKG/base_vpkg.yaml
- vPacketGenerator environment file: https://git.onap.org/demo/plain/heat/vFWCL/vPKG/base_vpkg.env

VVP Report
~~~~~~~~~~

:download:`vFWCL/vPKG report <files/vFWCL_vPKG_report.json>`

:download:`vFWCL/vFWSNK report <files/vFWCL_vFWSNK_report.json>`

Description
~~~~~~~~~~~

The use case is composed of three virtual functions (VFs): packet generator, firewall, and traffic sink. 
These VFs run in three separate VMs. The packet generator sends packets to the packet sink through the firewall. 
The firewall reports the volume of traffic passing though to the ONAP DCAE collector. To check the traffic volume 
that lands at the sink VM, you can access the link http://sink_ip_address:667 through your browser and enable 
automatic page refresh by clicking the "Off" button. You can see the traffic volume in the charts.

The packet generator includes a script that periodically generates different volumes of traffic. The closed-loop 
policy has been configured to re-adjust the traffic volume when high-water or low-water marks are crossed.


Closed-Loop for vFirewall Use Case
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Through the ONAP Portal's Policy Portal, we can find the configuration and operation policies that are currently 
enabled for the vFirewall use case:

- The configuration policy sets the thresholds for generating an onset event from DCAE to the Policy engine. Currently, the high-water mark is set to 700 packets while the low-water mark is set to 300 packets. The measurement interval is set to 10 seconds.
- When a threshold is crossed (i.e. the number of received packets is below 300 packets or above 700 packets per 10 seconds), the Policy engine executes the operational policy to request APPC to adjust the traffic volume to 500 packets per 10 seconds.
- APPC sends a request to the packet generator to adjust the traffic volume. 
- Changes to the traffic volume can be observed through the link http://sink_ip_address:667.


Adjust packet generator
~~~~~~~~~~~~~~~~~~~~~~~

The packet generator contains 10 streams: fw_udp1, fw_udp2, fw_udp3, ..., fw_udp10. Each stream generates 100 packets 
per 10 seconds. A script in /opt/run_traffic_fw_demo.sh on the packet generator VM starts automatically and alternates high 
traffic (i.e. 10 active streams at the same time) and low traffic (1 active stream) every 5 minutes.

To enable a stream, include

::

 {"id":"fw_udp1", "is-enabled":"true"} in the pg-stream bracket 

To adjust the traffic volume produced by the packet generator, run the following command in a shell, replacing PacketGen_IP in 
the HTTP argument with localhost (if you run it in the packet generator VM) or the packet generator IP address:

::

 curl -X PUT -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{"pg-streams":{"pg-stream": [{"id":"fw_udp1", "is-enabled":"true"},{"id":"fw_udp2", "is-enabled":"true"},{"id":"fw_udp3", "is-enabled":"true"},{"id":"fw_udp4", "is-enabled":"true"},{"id":"fw_udp5", "is-enabled":"true"}]}}' "http://PacketGen_IP:8183/restconf/config/sample-plugin:sample-plugin/pg-streams"

The command above enables 5 streams.


Running the Use Case
~~~~~~~~~~~~~~~~~~~~
Users can run the use case using the automated Robot Framework or manually. For using the Robot Framework in an ONAP instance installed with OOM, users have to connect to the Rancher VM and run the following command:

::

  bash oom/kubernetes/robot/demo-k8s.sh <namespace> vfwclosedloop <pgn-ip-address>

The script sets the packet generator to high and low rates, and checks whether the policy kicks in to modulate the rates back to medium.

For documentation about running the use case manually for previous releases, please look at the videos and the material available at this `wiki page`__.

__ https://wiki.onap.org/display/DW/Running+the+ONAP+Demos

Although videos are still valid, users are encouraged to use the Heat templates linked at the top of this page rather than the old Heat templates in that wiki page.

Known issues and resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~~
The packet generator may become unresponsive to external inputs like changing the number of active streams. To solve the problem, reboot the packet generator VM.