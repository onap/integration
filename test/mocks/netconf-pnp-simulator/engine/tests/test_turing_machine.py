import unittest
import nctest
import os

class TestTuringMachine(nctest.NCTestCase):
    """ Tests basic NETCONF operations on the turing-machine YANG module. """

    def __init__(self, *args, **kwargs):
        super(TestTuringMachine, self).__init__(*args, **kwargs)
        self.ns = {"nc": "urn:ietf:params:xml:ns:netconf:base:1.0", "tm": "http://example.net/turing-machine"}

    def check_deltas_in_data(self, data):
        deltas = data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/tm:transition-function/*", namespaces=self.ns)
        self.assertNotEqual(len(deltas), 0)
        for d in deltas:
            self.assertTrue(d.tag.endswith("delta"))

    def check_labels_only_in_data(self, data):
        children = data.xpath("/nc:rpc-reply/nc:data/*", namespaces=self.ns)
        self.assertNotEqual(len(children), 0)
        for child in children:
            self.assertTrue(child.tag.endswith("turing-machine"))
        children = data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/*", namespaces=self.ns)
        self.assertNotEqual(len(children), 0)
        for child in children:
            self.assertTrue(child.tag.endswith("transition-function"))
        children = data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/tm:transition-function/*", namespaces=self.ns)
        self.assertNotEqual(len(children), 0)
        for child in children:
            self.assertTrue(child.tag.endswith("delta"))
        children = data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/tm:transition-function/tm:delta/*", namespaces=self.ns)
        self.assertNotEqual(len(children), 0)
        for child in children:
            self.assertTrue(child.tag.endswith("label"))

    def test_get(self):
        reply = self.nc.get()
        self.check_reply_data(reply)
        self.check_deltas_in_data(reply.data)

    def test_get_config_startup(self):
        reply = self.nc.get_config(source="startup")
        self.check_reply_data(reply)
        self.check_deltas_in_data(reply.data)

    def test_get_config_running(self):
        reply = self.nc.get_config(source="running")
        self.check_reply_data(reply)
        self.check_deltas_in_data(reply.data)

    def test_get_subtree_filter(self):
        filter_xml = """<nc:filter xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
            <turing-machine xmlns="http://example.net/turing-machine">
                <transition-function>
                    <delta>
                        <label />
                    </delta>
                </transition-function>
            </turing-machine>
            </nc:filter>"""
        reply = self.nc.get_config(source="running", filter=filter_xml)
        self.check_reply_data(reply)
        self.check_deltas_in_data(reply.data)
        self.check_labels_only_in_data(reply.data)

    def test_get_xpath_filter(self):
        # https://github.com/ncclient/ncclient/issues/166
        filter_xml = """<nc:filter type="xpath" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"
            xmlns:tm="http://example.net/turing-machine"
            select="/tm:turing-machine/transition-function/delta/label" />
            """
        reply = self.nc.get(filter=filter_xml)
        self.check_reply_data(reply)
        self.check_deltas_in_data(reply.data)
        self.check_labels_only_in_data(reply.data)

    @unittest.skipIf(os.environ.get("DOCKER_IMG_TAG") == "latest", "bug in Netopeer2 replace operation")
    def test_edit_config(self):
        config_xml = """<nc:config xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
            <turing-machine xmlns="http://example.net/turing-machine">
                <transition-function>
                    <delta nc:operation="{}">
                        <label>test-transition-rule</label>
                        <input>
                            <symbol>{}</symbol>
                            <state>{}</state>
                        </input>
                    </delta>
                </transition-function>
            </turing-machine></nc:config>"""
        # merge
        reply = self.nc.edit_config(target='running', config=config_xml.format("merge", 9, 99))
        self.check_reply_ok(reply)
        # get
        reply = self.nc.get_config(source="running")
        self.check_reply_data(reply)
        deltas = reply.data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/tm:transition-function/tm:delta[tm:label='test-transition-rule']", namespaces=self.ns)
        self.assertEqual(len(deltas), 1)
        # create already existing - expect error
        reply = self.nc.edit_config(target='running', config=config_xml.format("create", 9, 99))
        self.check_reply_err(reply)
        # replace
        reply = self.nc.edit_config(target='running', config=config_xml.format("replace", 9, 88))
        self.check_reply_ok(reply)
        # get
        reply = self.nc.get_config(source="running")
        self.check_reply_data(reply)
        states = reply.data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/tm:transition-function/tm:delta[tm:label='test-transition-rule']/tm:input/tm:state", namespaces=self.ns)
        self.assertEqual(len(states), 1)
        self.assertEqual(states[0].text, "88")
        # delete
        reply = self.nc.edit_config(target='running', config=config_xml.format("delete", 9, 88))
        self.check_reply_ok(reply)
        # delete non-existing - expect error
        reply = self.nc.edit_config(target='running', config=config_xml.format("delete", 9, 88))
        self.check_reply_err(reply)
        # get - should be empty
        reply = self.nc.get_config(source="running")
        self.check_reply_data(reply)
        deltas = reply.data.xpath("/nc:rpc-reply/nc:data/tm:turing-machine/tm:transition-function/tm:delta[tm:label='test-transition-rule']", namespaces=self.ns)
        self.assertEqual(len(deltas), 0)

if __name__ == '__main__':
    unittest.main()
