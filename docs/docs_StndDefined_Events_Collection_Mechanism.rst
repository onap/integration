.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_StndDefined_Events_Collection_Mechanism:

:orphan:

VES Collector - Standard Defined Events Collection Mechanism
------------------------------------------------------------

Description
~~~~~~~~~~~

The target of standard defined events collection mechanism development was to allow collection of events defined by standards organizations using VES Collector,
and providing them for consumption by analytics applications running on top of DCAE platform. The following features have been implemented:

1. Event routing, based on a new CommonHeader field “stndDefinedNamespace”
2. Standards-organization defined events can be included using a dedicated stndDefinedFields.data property
3. Standards-defined events can be validated using openAPI descriptions provided by standards organizations, and indicated in stndDefinedFields.schemaReference

`Standard Defined Events Collection Mechanism description <https://docs.onap.org/projects/onap-dcaegen2/en/honolulu/sections/services/ves-http/stnd-defined-validation.html>`_

.. note::

   VES Collector orchestrated using Helm or Cloudify uses standard defined domain schema files bundled within VES collector image during image build.
   Also new Helm based installation mechanism for collectors doesn't support yet certain features available with the traditional Cloudify orchestration based mechanisms:
      - Obtaining X.509 certificates from external CMP v2 server for secure xNF connections
      - Exposing the Collector port in Dual Stack IPv4/IPv6 networks.


How to Configure VES Collector
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default config maps containing schema files are defined in the `OOM <https://github.com/onap/oom/tree/honolulu/kubernetes/dcaegen2/resources/external>`_ repository and installed with dcaegen2 module.
In Istanbul release in OOM are used schema files from https://forge.3gpp.org/rep/sa5/MnS/blob/SA88-Rel16/OpenAPI/.
The newest schema files can be found in https://forge.3gpp.org/rep/sa5/MnS/tree/Rel-16-SA-91/OpenAPI
If for production/test purpose are required different or newest schema files please follow procedure for `config map update <https://docs.onap.org/projects/onap-dcaegen2/en/latest/sections/configuration.html#config-maps>`_.

In order to prepare second instance of VES Collector please follow below procedure:

1. (Optional step) If VES Collector should obtaining X.509 certificates from CMPv2 server for secure xNF connections please follow below steps:

   - Install `Cert Manager <https://docs.onap.org/projects/onap-oom/en/latest/oom_setup_paas.html#cert-manager>`_
   - Configure `Cert Service <https://docs.onap.org/projects/onap-oom-platform-cert-service/en/honolulu/sections/configuration.html>`_ if external CMP v2 server is in use.

2. If usage of config maps from OOM containing schema files is required please follow procedure for
   `external repo schema files from OOM connection to VES collector <https://docs.onap.org/projects/onap-dcaegen2/en/honolulu/sections/services/ves-http/installation.html#external-repo-schema-files-from-oom-connection-to-ves-collector>`_
   with changes described below.

   As new instance of VES Collector will be introduced to ONAP namespace there is need to modify parameters from ``/inputs/k8s-ves-inputs-tls.yaml`` in Bootstrap POD

   - external_port - set here ``node port`` from range ``30000-32767`` not used in ONAP instance for example ``30519``
   - ``service_component_type``, ``service_id``, ``service_component_name_override`` - set here custom service name e.g. ``dcae-ves-collector-std-def-evnents``

   (Optional step) If VES Collector should also obtaining X.509 certificates from CMP v2 and its clients should successfully validate its hostname then following parameters need to modified in ``/inputs/k8s-ves-inputs-tls.yaml`` file.

   - ``external_cert_use_external_tls`` - change from ``false`` to ``true``
   - ``external_cert_common_name`` - set same value as used in ``service_component_name_override parameter``
   - ``service_component_name_override`` - add following values:
      - all IPv4 addresses of ONAP worker hosts
      - all IPv6 addresses of ONAP worker hosts
      - all FQDN names of ONAP worker hosts
      - ``service_component_name_override`` parameter value.

   Deploy new instance of VES collector using ``/inputs/k8s-ves-inputs-tls.yaml``

3. (Optional step) If ONAP is installed in Dual Stack and VES Collector should listen in IPv6 network

   - on RKE node prepare file ``ves-ipv6.yaml`` with following content (below is an example of file for ``dcae-ves-collector-std-def-evnents`` service name created in section 2,  in  ``node port`` set once again value from range ``30000-32767`` not used in ONAP instance for example ``30619`` )
       .. code-block:: bash

         apiVersion: v1
         kind: Service
         metadata:
           name: xdcae-ves-collector-std-def-evnents
           namespace: onap
         spec:
           externalTrafficPolicy: Cluster
           ipFamily: IPv6
           ports:
           - name: xdcae-ves-collector-std-def-evnents
             nodePort: 30619
             port: 8443
             protocol: TCP
             targetPort: 8443
           selector:
             app: dcae-ves-collector-std-def-evnents
           sessionAffinity: None
           type: NodePort

   - apply prepared service and check if it working
       .. code-block:: bash

         kubectl -n onap apply -f ves-ipv6.yaml

         kubectl -n onap get svc | grep collector-std-def-evnents
         xdcae-ves-collector-std-def-evnents                        NodePort       fd00:101::6ad    <none>                                 8443:30619/TCP