import unittest
import nctest

class TestBasicOperations(nctest.NCTestCase):
    """ Tests basic NETCONF operations with no prerequisites on datastore content. """

    def test_capabilities(self):
        self.assertTrue(":startup" in self.nc.server_capabilities)
        self.assertTrue(":candidate" in self.nc.server_capabilities)
        self.assertTrue(":validate" in self.nc.server_capabilities)
        self.assertTrue(":xpath" in self.nc.server_capabilities)

    def test_get(self):
        reply = self.nc.get()
        self.check_reply_data(reply)

    def test_get_config_startup(self):
        reply = self.nc.get_config(source='startup')
        self.check_reply_data(reply)

    def test_get_config_running(self):
        reply = self.nc.get_config(source='running')
        self.check_reply_data(reply)

    def test_copy_config(self):
        reply = self.nc.copy_config(source='startup', target='candidate')
        self.check_reply_ok(reply)

    def test_neg_filter(self):
        reply = self.nc.get(filter=("xpath", "/non-existing-module:non-existing-data"))
        self.check_reply_err(reply)

    def test_lock(self):
        reply = self.nc.lock("startup")
        self.check_reply_ok(reply)
        reply = self.nc.lock("running")
        self.check_reply_ok(reply)
        reply = self.nc.lock("candidate")
        self.check_reply_ok(reply)

        reply = self.nc.lock("startup")
        self.check_reply_err(reply)

        reply = self.nc.unlock("startup")
        self.check_reply_ok(reply)
        reply = self.nc.unlock("running")
        self.check_reply_ok(reply)
        reply = self.nc.unlock("candidate")
        self.check_reply_ok(reply)

if __name__ == '__main__':
    unittest.main()
