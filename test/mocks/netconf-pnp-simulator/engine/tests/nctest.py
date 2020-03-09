from ncclient import manager, operations
import settings
import unittest

class NCTestCase(unittest.TestCase):
    """ Base class for NETCONF test cases. Provides a NETCONF connection and some helper methods. """

    def setUp(self):
        self.nc = manager.connect(
            host=settings.HOST,
            port=settings.PORT,
            username=settings.USERNAME,
            key_filename=settings.KEY_FILENAME,
            allow_agent=False,
            look_for_keys=False,
            hostkey_verify=False)
        self.nc.raise_mode = operations.RaiseMode.NONE

    def tearDown(self):
        self.nc.close_session()

    def check_reply_ok(self, reply):
        self.assertIsNotNone(reply)
        if settings.DEBUG:
            print(reply.xml)
        self.assertTrue(reply.ok)
        self.assertIsNone(reply.error)

    def check_reply_err(self, reply):
        self.assertIsNotNone(reply)
        if settings.DEBUG:
            print(reply.xml)
        self.assertFalse(reply.ok)
        self.assertIsNotNone(reply.error)

    def check_reply_data(self, reply):
        self.check_reply_ok(reply)
