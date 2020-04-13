.. _docs_vfw:

vFirewall Use Case
------------------

Source files
~~~~~~~~~~~~

- vFirewall/vSink template file: https://git.onap.org/demo/tree/heat/vFWCL/vFWSNK/base_vfw.yaml?h=elalto
- vFirewall/vSink environment file: https://git.onap.org/demo/tree/heat/vFWCL/vFWSNK/base_vfw.env?h=elalto

- vPacketGenerator template file: https://git.onap.org/demo/tree/heat/vFWCL/vPKG/base_vpkg.env?h=elalto
- vPacketGenerator environment file: https://git.onap.org/demo/tree/heat/vFWCL/vPKG/base_vpkg.env?h=elalto

VVP Report
~~~~~~~~~~

:download:`vFWCL/vPKG report <files/vFWCL_vPKG_report.json>`

:download:`vFWCL/vFWSNK report <files/vFWCL_vFWSNK_report.json>`

Description
~~~~~~~~~~~

The use case, introduced in Amsterdam version, is composed of three virtual
functions (VFs): packet generator, firewall, and traffic sink.
These VFs run in three separate VMs. The packet generator sends packets to the
packet sink through the firewall.
The firewall reports the volume of traffic passing though to the ONAP DCAE
collector. To check the traffic volume that lands at the sink VM, you can access
the link <http://SINK_IP_ADDRESS:667> through your browser and enable automatic page
refresh by clicking the "Off" button. You can see the traffic volume in the charts.

The packet generator includes a script that periodically generates different
volumes of traffic. The closed-loop policy has been configured to re-adjust the
traffic volume when high-water or low-water marks are crossed.

Since Casablanca, we have used a vFWCL service tag for this testing instead of
the vFW service tag. vFW servic tag is a regression for onboard and
instantiation of a single VNF service (all three VMs in the same VNF) where as the
vFWCL is a two VNF service (vFW+ vSNK and separeate vPKG)

./demo-k8s.sh onap instantiateVFWCL can be used to onboard and instantiate a
vFWCL via robot scripts or follow the procedure to use the GUI that is available
in the documentation.


Closed-Loop for vFirewall Use Case
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Through the ONAP Portal's Policy Portal, we can find the configuration and
operation policies that are currently enabled for the vFirewall use case:

- The configuration policy sets the thresholds for generating an onset event
  from DCAE to the Policy engine. Currently, the high-water mark is set to 700
  packets while the low-water mark is set to 300 packets.
  The measurement interval is set to 10 seconds.
- When a threshold is crossed (i.e. the number of received packets is below 300
  packets or above 700 packets per 10 seconds), the Policy engine executes the
  operational policy to request APPC to adjust the traffic volume to 500 packets
  per 10 seconds.
- APPC sends a request to the packet generator to adjust the traffic volume.
- Changes to the traffic volume can be observed through the link <http://SINK_IP_ADDRESS:667>.


Adjust packet generator
~~~~~~~~~~~~~~~~~~~~~~~

The packet generator contains 10 streams: fw_udp1, fw_udp2, fw_udp3, ..., fw_udp10.
Each stream generates 100 packets per 10 seconds.
A script in /opt/run_traffic_fw_demo.sh on the packet generator VM starts
automatically and alternates high traffic (i.e. 10 active streams at the same
time) and low traffic (1 active stream) every 5 minutes.

To adjust the traffic volume produced by the packet generator, run the following
command in a shell, replacing PacketGen_IP in the HTTP argument with localhost
(if you run it in the packet generator VM) or the packet generator IP address:

::

  curl -X PUT \
  https://PacketGen_IP:8445/restconf/config/stream-count:stream-count/streams \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 88610924-938b-4d64-a682-0b0aabed4a6d' \
  -H 'cache-control: no-cache' \
  -d '{
    "streams": {
        "active-streams": 5
    }}'


The command above enables 5 streams.

Running the Use Case
~~~~~~~~~~~~~~~~~~~~

Users can run the use case using the automated Robot Framework or manually.
For using the Robot Framework in an ONAP instance installed with OOM, users have
to ssh to the Rancher VM and run the following command:

::

  bash oom/kubernetes/robot/demo-k8s.sh <namespace> vfwclosedloop <pgn-ip-address>

The script sets the packet generator to high and low rates, and checks whether
the policy kicks in to modulate the rates back to medium.
At the end of the test , robot sets the streams back to Medium so that it is
setup for the next test.

For documentation about running the use case manually for previous releases,
please look at the videos and the material available at this `wiki page`__.

__ https://wiki.onap.org/display/DW/Running+the+ONAP+Demos

Although videos are still valid, users are encouraged to use the Heat templates
linked at the top of this page rather than the old Heat templates in that wiki page.

Known issues and resolution
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The packet generator may become unresponsive to external inputs like changing
the number of active streams.
To solve the problem, reboot the packet generator VM.

Policy can lock the target VNF if there are too many failed attempts due to
mis-configuration etc.
Set the streams to medium and wait 30 minutes or so and the lock in policy will
expire. Monitoring the DMaaP topic for DCAE_CL_OUTPUT can be used to confirm
that no TCA events are coming in from the VNF through VES/TCA.

::
   http://K8S_HOST:30227/events/unauthenticated.DCAE_CL_OUTPUT/g1/c3?timeout=5000

+-------------+------------+
| JIRA ID     | Status     |
+=============+============+
| POLICY-2109 | Closed     |
+-------------+------------+
| INT-1272    | Closed     |
+-------------+------------+
