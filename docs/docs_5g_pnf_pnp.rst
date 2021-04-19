.. This work is licensed under a Creative Commons Attribution 4.0
   International License. http://creativecommons.org/licenses/by/4.0

.. _docs_5g_pnf_pnp:

:orphan:

5G - PNF Plug and Play
----------------------

Description
~~~~~~~~~~~

The PNF Plug and Play is a procedure that is executed between a PNF and ONAP. In the process of PNF registration, ONAP establishes a PNF resource instance for the PNF with a corresponding A&AI entry. The PNF registration uses a VES exchange with the PNF Registration handler within ONAP to complete the registration. Allowing the PNF resource instance to be associated with an existing service instance. This use case is intended to be applicable to a variety of PNFs such as routers and 5G base stations. The steps and descriptions have been drafted to be as general as possible and to be applicable to a relatively wide variety of PNFs. However, the use case was originally developed with a consideration for 5G PNF Distributed Units (DU).

**Useful Links**

1. `5G - PNF Plug and Play use case documentation <https://wiki.onap.org/display/DW/5G+-+PNF+Plug+and+Play>`_
2. `5G - PNF Plug and Play - Integration Test Cases <https://wiki.onap.org/display/DW/5G+-+PNF+PnP+-+Integration+Test+Cases>`_
3. Instruction how to setup and use VES CLinet from :ref:`NF Simulator <nf_simulator>`.

How to Use
~~~~~~~~~~

1. Create and distribute service model which contains PNF
2. Create service for PNF and wait for PNF Ready message in DmaaP topic
3. Send PNF Registartion request from NF Simualtor (VES Client) and finish registration

Below is present an example of event that need to be send to VES Client in order to trigger registration event from VES Client to ONAP VES Collector.
There is need to fill following values in example json with proper values:

1. dcae-ves-collector-host-name
2. dcae-ves-collector-port
3. sourceName - Identifier of this Pnf information element. It is the first three letters of the Vendor and the PNF serial number.
   This is a unique identifier for the PNF instance. It is also referred to as the Correlation ID.
4. oamV4IpAddress - This is the IP address (IPv4) for the PNF itself. This is the IPv4 address that the PNF itself can be accessed at.
5. oamV6IpAddress - This is the IP address (IPv6) for the PNF itself. This is the IPv6 address that the PNF itself can be accessed at.

::

   {
     "vesServerUrl": "https://<dcae-ves-collector-host-name>:<dcae-ves-collector-port>/eventListener/v7",
     "event": {
       "event": {
         "commonEventHeader": {
           "startEpochMicrosec": 1538407540940,
           "sourceId": "val13",
           "eventId": "registration_38407540",
           "nfcNamingCode": "oam",
           "internalHeaderFields": {},
           "eventType": "pnfRegistration",
           "priority": "Normal",
           "version": "4.0.1",
           "reportingEntityName": "VEN6061ZW3",
           "sequence": 0,
           "domain": "pnfRegistration",
           "lastEpochMicrosec": 1538407540940,
           "eventName": "pnfRegistration",
           "vesEventListenerVersion": "7.0.1",
           "sourceName": "<sourceName>",
           "nfNamingCode": "gNB"
         },
         "pnfRegistrationFields": {
           "unitType": "val8",
           "serialNumber": "6061ZW3",
           "pnfRegistrationFieldsVersion": "2.0",
           "manufactureDate": "1538407540942",
           "modelNumber": "val6",
           "lastServiceDate": "1538407540942",
           "unitFamily": "BBU",
           "vendorName": "VENDOR",
           "oamV4IpAddress": "<oamV4IpAddress>,
           "oamV6IpAddress": "<oamV6IpAddress>",
           "softwareVersion": "val7"
         }
       }
     }
   }


