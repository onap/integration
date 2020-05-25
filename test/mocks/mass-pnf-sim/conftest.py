import MassPnfSim
import pytest
from test_settings import * # pylint: disable=W0614

@pytest.fixture(scope="module")
def parser():
    return MassPnfSim.get_parser()

@pytest.fixture(scope="module")
def args_bootstrap(parser):
    return parser.parse_args(['bootstrap', '--count', str(SIM_INSTANCES),
                             '--urlves', URLVES, '--ipfileserver', IPFILESERVER,
                             '--typefileserver', TYPEFILESERVER, '--ipstart',
                             IPSTART])

@pytest.fixture(scope="module")
def args_start(parser):
    return parser.parse_args(['start'])

@pytest.fixture(scope="module")
def args_stop(parser):
    return parser.parse_args(['stop'])

@pytest.fixture(scope="module")
def args_status(parser):
    return parser.parse_args(['status'])

@pytest.fixture(scope="module")
def args_trigger(parser):
    return parser.parse_args(['trigger'])

@pytest.fixture(scope="module")
def args_trigger_custom(parser):
    return parser.parse_args(['trigger_custom', '--triggerstart', '0', '--triggerend', str(SIM_INSTANCES-1)])
