import nctest


class TestBasicOperations(nctest.NCTestCase):
    """ Tests basic NETCONF operations with no prerequisites on datastore content. """

    def test_capabilities(self):
        assert ":startup" in self.nc.server_capabilities
        assert ":candidate" in self.nc.server_capabilities
        assert ":validate" in self.nc.server_capabilities
        assert ":xpath" in self.nc.server_capabilities

    def test_get(self):
        reply = self.nc.get()
        nctest.check_reply_data(reply)

    def test_get_config_startup(self):
        reply = self.nc.get_config(source='startup')
        nctest.check_reply_data(reply)

    def test_get_config_running(self):
        reply = self.nc.get_config(source='running')
        nctest.check_reply_data(reply)

    def test_copy_config(self):
        reply = self.nc.copy_config(source='startup', target='candidate')
        nctest.check_reply_ok(reply)

    def test_neg_filter(self):
        reply = self.nc.get(filter=("xpath", "/non-existing-module:non-existing-data"))
        nctest.check_reply_err(reply)

    def test_lock(self):
        reply = self.nc.lock("startup")
        nctest.check_reply_ok(reply)
        reply = self.nc.lock("running")
        nctest.check_reply_ok(reply)
        reply = self.nc.lock("candidate")
        nctest.check_reply_ok(reply)

        reply = self.nc.lock("startup")
        nctest.check_reply_err(reply)

        reply = self.nc.unlock("startup")
        nctest.check_reply_ok(reply)
        reply = self.nc.unlock("running")
        nctest.check_reply_ok(reply)
        reply = self.nc.unlock("candidate")
        nctest.check_reply_ok(reply)
