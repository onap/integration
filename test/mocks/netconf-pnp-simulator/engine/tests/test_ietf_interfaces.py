import unittest
import nctest
import os

class TestIETFInterfaces(nctest.NCTestCase):
    """ Tests basic NETCONF operations on the turing-machine YANG module. """

    def __init__(self, *args, **kwargs):
        super(TestIETFInterfaces, self).__init__(*args, **kwargs)
        self.ns = {"nc": "urn:ietf:params:xml:ns:netconf:base:1.0", "if": "urn:ietf:params:xml:ns:yang:ietf-interfaces"}

    def test_edit_config(self):
        config_xml = """<nc:config xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
            <interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces">
                <interface nc:operation="{}">
                    <name>TestInterface</name>
                    <description>Interface under test</description>
                    <type xmlns:ianaift="urn:ietf:params:xml:ns:yang:iana-if-type">ianaift:ethernetCsmacd</type>
                    <ipv4 xmlns="urn:ietf:params:xml:ns:yang:ietf-ip">
                        <mtu>1500</mtu>
                        <address>
                            <ip>192.168.2.100</ip>
                            <prefix-length>24</prefix-length>
                        </address>
                    </ipv4>
                    <ipv6 xmlns="urn:ietf:params:xml:ns:yang:ietf-ip">
                        <address>
                            <ip>2001:db8::10</ip>
                            <prefix-length>32</prefix-length>
                        </address>
                    </ipv6>
                </interface>
            </interfaces>
        </nc:config>"""

        filter_xml = """<nc:filter xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
            <interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces" />
            </nc:filter>"""

        with_default_report_all = """report-all"""

        # get from running - should be empty
        reply = self.nc.get_config(source="running", filter=filter_xml)
        self.check_reply_data(reply)
        deltas = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']", namespaces=self.ns)
        self.assertEqual(len(deltas), 0)

        # set data - candidate
        reply = self.nc.edit_config(target='candidate', config=config_xml.format("merge"))
        self.check_reply_ok(reply)

        # get from candidate
        reply = self.nc.get_config(source="candidate", filter=filter_xml)
        self.check_reply_data(reply)
        interfaces = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']", namespaces=self.ns)
        self.assertEqual(len(interfaces), 1)

        # default leaf should NOT be present
        enabled = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']/enabled", namespaces=self.ns)
        self.assertEqual(len(enabled), 0)

        # get from candidate with with defaults = 'report-all'
        reply = self.nc.get_config(source="candidate", filter=filter_xml, with_defaults=with_default_report_all)
        self.check_reply_data(reply)
        interfaces = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']", namespaces=self.ns)
        self.assertEqual(len(interfaces), 1)

        # default leaf should be present
        enabled = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']/enabled", namespaces=self.ns)
        self.assertEqual(len(enabled), 0) # TODO: change to 1 once this is implemented

        # get from running - should be empty
        reply = self.nc.get_config(source="running", filter=filter_xml)
        self.check_reply_data(reply)
        deltas = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']", namespaces=self.ns)
        self.assertEqual(len(deltas), 0)

        # commit - should fail, not enabled in running
        reply = self.nc.commit()
        self.check_reply_err(reply)

        # delete from candidate
        reply = self.nc.edit_config(target='candidate', config=config_xml.format("delete"))
        self.check_reply_ok(reply)

        # get from candidate - should be empty
        reply = self.nc.get_config(source="candidate", filter=filter_xml)
        self.check_reply_data(reply)
        deltas = reply.data.xpath("/nc:rpc-reply/nc:data/if:interfaces/if:interface[if:name='TestInterface']", namespaces=self.ns)
        self.assertEqual(len(deltas), 0)

if __name__ == '__main__':
    unittest.main()
