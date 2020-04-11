from nctest import *


class TestBasicOperations(NCTestCase):
    """ Tests basic NETCONF operations with no prerequisites on datastore content. """

    def test_capabilities(self):
        assert ":startup" in self.nc.server_capabilities
        assert ":candidate" in self.nc.server_capabilities
        assert ":validate" in self.nc.server_capabilities
        assert ":xpath" in self.nc.server_capabilities

    def test_get(self):
        reply = self.nc.get()
        check_reply_data(reply)

    def test_get_config_startup(self):
        reply = self.nc.get_config(source='startup')
        check_reply_data(reply)

    def test_get_config_running(self):
        reply = self.nc.get_config(source='running')
        check_reply_data(reply)

    def test_copy_config(self):
        reply = self.nc.copy_config(source='startup', target='candidate')
        check_reply_ok(reply)

    def test_neg_filter(self):
        reply = self.nc.get(filter=("xpath", "/non-existing-module:non-existing-data"))
        check_reply_err(reply)

    def test_lock(self):
        reply = self.nc.lock("startup")
        check_reply_ok(reply)
        reply = self.nc.lock("running")
        check_reply_ok(reply)
        reply = self.nc.lock("candidate")
        check_reply_ok(reply)

        reply = self.nc.lock("startup")
        check_reply_err(reply)

        reply = self.nc.unlock("startup")
        check_reply_ok(reply)
        reply = self.nc.unlock("running")
        check_reply_ok(reply)
        reply = self.nc.unlock("candidate")
        check_reply_ok(reply)
