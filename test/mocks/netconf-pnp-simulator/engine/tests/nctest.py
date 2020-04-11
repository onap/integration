import logging.config

from ncclient import manager, operations

import settings

LOGGER = logging.getLogger(__name__)


def check_reply_ok(reply):
    assert reply is not None
    _log_netconf_msg("Received", reply.xml)
    assert reply.ok is True
    assert reply.error is None


def check_reply_err(reply):
    assert reply is not None
    _log_netconf_msg("Received", reply.xml)
    assert reply.ok is False
    assert reply.error is not None


def check_reply_data(reply):
    check_reply_ok(reply)


def _log_netconf_msg(header: str, body: str):
    """Log a message using a format inspired by NETCONF 1.1 """
    LOGGER.info("%s:\n\n#%d\n%s\n##", header, len(body), body)


class NCTestCase:
    """ Base class for NETCONF test cases. Provides a NETCONF connection and some helper methods. """

    nc: manager.Manager

    def setup(self):
        self.nc = manager.connect(
            host=settings.HOST,
            port=settings.PORT,
            username=settings.USERNAME,
            key_filename=settings.KEY_FILENAME,
            allow_agent=False,
            look_for_keys=False,
            hostkey_verify=False)
        self.nc.raise_mode = operations.RaiseMode.NONE

    def teardown(self):
        self.nc.close_session()
