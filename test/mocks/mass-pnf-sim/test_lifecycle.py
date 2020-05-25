from MassPnfSim import MassPnfSim
from glob import glob
from os import popen
from yaml import load, SafeLoader
from ipaddress import ip_address
from test_settings import *
import pytest

# These test routines perform functional testing in current file tree context
# thus they require that no simulator instances are bootstrapped and running
# prior to running tests

@pytest.mark.parametrize("action", ['start', 'stop', 'trigger', 'status'])
def test_not_bootstrapped(action, caplog, args_start, args_stop, args_trigger, args_status): # pylint: disable=W0613
    try:
        m = getattr(MassPnfSim(eval(f'args_{action}')), action)
        m()
    except SystemExit as e:
        assert e.code == 1
    assert 'No bootstrapped instance found' in caplog.text
    caplog.clear()

def test_bootstrap(args_bootstrap, parser, caplog):
    # Initial bootstrap
    MassPnfSim(args_bootstrap).bootstrap()
    for instance in range(SIM_INSTANCES):
        assert f'Creating pnf-sim-lw-{instance}' in caplog.text
        assert f'Done setting up instance #{instance}' in caplog.text
    caplog.clear()

    # Verify bootstrap idempotence
    try:
        MassPnfSim(args_bootstrap).bootstrap()
    except SystemExit as e:
        assert e.code == 1
    assert 'Bootstrapped instances detected, not overwiriting, clean first' in caplog.text
    caplog.clear()

    # Verify simulator dirs created
    sim_dirname_pattern = MassPnfSim(parser.parse_args([])).sim_dirname_pattern
    assert len(glob(f"{sim_dirname_pattern}*")) == SIM_INSTANCES

    # Verify ROP_file_creator.sh running
    for instance in range(SIM_INSTANCES):
        assert f"ROP_file_creator.sh {instance}" in popen('ps afx').read()

    # Verify simulators configs content is valid
    start_port = 2000
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        with open(f"{sim_dirname_pattern}{instance}/{INSTANCE_CONFIG}") as f:
            yml = load(f, Loader=SafeLoader)
        assert URLVES == yml['urlves']
        assert TYPEFILESERVER == yml['typefileserver']
        assert f'sftp://onap:pano@{IPFILESERVER}:{start_port + 1}' in yml['urlsftp']
        assert f'ftps://onap:pano@{IPFILESERVER}:{start_port + 2}' in yml['urlftps']
        assert str(ip_address(IPSTART) + ip_offset + instance_ip_offset) == yml['ippnfsim']
        start_port += 2
        print(yml['ippnfsim'])

def test_start(args_start, caplog, capfd):
    MassPnfSim(args_start).start()
    msg = capfd.readouterr()
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Starting pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP:  {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in msg.out
        assert 'Starting simulator containers' in msg.out
    caplog.clear()

def test_start_idempotence(args_start, capfd):
    '''Verify start idempotence'''
    MassPnfSim(args_start).start()
    msg = capfd.readouterr()
    assert 'Simulator containers are already up' in msg.out
    assert 'Starting simulator containers' not in msg.out
