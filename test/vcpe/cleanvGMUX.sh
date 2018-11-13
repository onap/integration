#! /usr/bin/env bash
#########################################################################################
#   Script to cleanpu vGMUX and other parts of the vCPE Use Case
#
# Edit the IP addresses and portas as appropriate
#
#######################################################################################


VGMUX_IP=10.12.6.242
#VBRG_IP=10.12.5.142
#SDNC_IP=10.12.5.180

#curl -X DELETE -u admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U http://$SDNC_IP:8282/restconf/config/GENERIC-RESOURCE-API:tunnelxconn-allotted-resources
#curl -X DELETE -u admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U http://$SDNC_IP:8282/restconf/config/GENERIC-RESOURCE-API:brg-allotted-resources

###################################
# vGMUX
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.3.0.2/v3po:l2
echo

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.5.0.22/v3po:l2
echo

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.5.0.22
echo

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.3.0.2
echo


curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.5.0.106
echo
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.5.0.107

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.5.0.111

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X DELETE http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.5.0.110

# Check by listing interfaces
echo "********************* vGMUX status ************************"
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X GET  http://$VGMUX_IP:8183/restconf/config/ietf-interfaces:interfaces| python -m json.tool


exit;

#########################################################################################
#  remove above exit if you want to interact with the other components
#########################################################################################



###################################
# vBRG
curl -u admin:admin -X DELETE http://$VBRG_IP:8183/restconf/config/ietf-interfaces:interfaces/interface/vxlanTun10.1.0.21

# check
echo "********************* vBRG status ************************"
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -u admin:admin -X GET  http://$VBRG_IP:8183/restconf/config/ietf-interfaces:interfaces| python -m json.tool



