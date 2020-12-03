from MassPnfSim import MassPnfSim
from glob import glob
from os import popen, stat
from yaml import load, SafeLoader
from ipaddress import ip_address
from test_settings import *
import pytest
from time import sleep

# These test routines perform functional testing in current file tree context
# thus they require that no simulator instances are bootstrapped and running
# prior to running tests

@pytest.mark.parametrize("action", ['start', 'stop', 'trigger', 'status', 'stop_simulator'])
def test_not_bootstrapped(action, caplog, args_start, args_stop, args_trigger, args_status, args_stop_simulator): # pylint: disable=W0613
    try:
        m = getattr(MassPnfSim(), action)
        m(eval(f'args_{action}'))
    except SystemExit as e:
        assert e.code == 1
    assert 'No bootstrapped instance found' in caplog.text
    caplog.clear()

def test_bootstrap(args_bootstrap, caplog):
    # Initial bootstrap
    MassPnfSim().bootstrap(args_bootstrap)
    for instance in range(SIM_INSTANCES):
        assert f'Creating pnf-sim-lw-{instance}' in caplog.text
        assert f'Done setting up instance #{instance}' in caplog.text
    caplog.clear()

    # Verify bootstrap idempotence
    try:
        MassPnfSim().bootstrap(args_bootstrap)
    except SystemExit as e:
        assert e.code == 1
    assert 'Bootstrapped instances detected, not overwiriting, clean first' in caplog.text
    caplog.clear()

    # Verify simulator dirs created
    sim_dirname_pattern = MassPnfSim().sim_dirname_pattern
    assert len(glob(f"{sim_dirname_pattern}*")) == SIM_INSTANCES

    # Verify simulators configs content is valid
    start_port = 2000
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        with open(f"{sim_dirname_pattern}{instance}/{INSTANCE_CONFIG}") as f:
            yml = load(f, Loader=SafeLoader)
        assert URLVES == yml['urlves']
        assert TYPEFILESERVER == yml['typefileserver']
        assert f'sftp://{USER}:{PASSWORD}@{IPFILESERVER}:{start_port + 1}' in yml['urlsftp']
        assert f'ftps://{USER}:{PASSWORD}@{IPFILESERVER}:{start_port + 2}' in yml['urlftps']
        assert str(ip_address(IPSTART) + ip_offset + instance_ip_offset) == yml['ippnfsim']
        start_port += 2
        print(yml['ippnfsim'])

    # Verify vsftpd config file has proper permissions
    for cfg in glob(f'{sim_dirname_pattern}*/config/vsftpd_ssl.conf'):
        assert stat(cfg).st_uid == 0

def test_bootstrap_status(args_status, caplog):
    MassPnfSim().status(args_status)
    for _ in range(SIM_INSTANCES):
        assert 'Simulator containers are down' in caplog.text
        assert 'Simulator response' not in caplog.text
    caplog.clear()

def test_start(args_start, caplog):
    MassPnfSim().start(args_start)
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Starting pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP: {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in caplog.text
        assert 'Starting simulator containers' in caplog.text
        assert f"ROP_file_creator.sh {instance} successfully started" in caplog.text
        assert f"3GPP measurements file generator for instance {instance} is already running" not in caplog.text
        # Verify ROP_file_creator.sh running
        assert f"ROP_file_creator.sh {instance}" in popen('ps afx').read()
    caplog.clear()

def test_start_status(args_status, docker_containers, caplog):
    sleep(5) # Wait for the simulator to settle
    MassPnfSim().status(args_status)
    for instance in range(SIM_INSTANCES):
        assert '"simulatorStatus":"NOT RUNNING"' in caplog.text
        assert '"simulatorStatus":"RUNNING"' not in caplog.text
        assert f"{PNF_SIM_CONTAINER_NAME}{instance}" in docker_containers
    caplog.clear()

def test_start_idempotence(args_start, caplog):
    '''Verify start idempotence'''
    MassPnfSim().start(args_start)
    assert 'containers are already up' in caplog.text
    assert 'Starting simulator containers' not in caplog.text
    assert f"is already running" in caplog.text
    caplog.clear()

def test_trigger(args_trigger, caplog):
    MassPnfSim().trigger(args_trigger)
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Triggering pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP: {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in caplog.text
        assert 'Simulator started' in caplog.text
    caplog.clear()

def test_trigger_status(args_status, capfd, caplog):
    MassPnfSim().status(args_status)
    msg = capfd.readouterr()
    for _ in range(SIM_INSTANCES):
        assert '"simulatorStatus":"RUNNING"' in caplog.text
        assert '"simulatorStatus":"NOT RUNNING"' not in caplog.text
        assert 'Up' in msg.out
        assert 'Exit' not in msg.out
    caplog.clear()

def test_trigger_idempotence(args_trigger, caplog):
    MassPnfSim().trigger(args_trigger)
    assert "Cannot start simulator since it's already running" in caplog.text
    assert 'Simulator started' not in caplog.text
    caplog.clear()

def test_stop_simulator(args_stop_simulator, caplog):
    MassPnfSim().stop_simulator(args_stop_simulator)
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Stopping pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP: {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in caplog.text
        assert "Simulator successfully stopped" in caplog.text
        assert "not running" not in caplog.text
    caplog.clear()

def test_stop_simulator_status(args_status, capfd, caplog):
    MassPnfSim().status(args_status)
    msg = capfd.readouterr()
    for _ in range(SIM_INSTANCES):
        assert '"simulatorStatus":"RUNNING"' not in caplog.text
        assert '"simulatorStatus":"NOT RUNNING"' in caplog.text
        assert 'Up' in msg.out
        assert 'Exit' not in msg.out
    caplog.clear()

def test_stop_simulator_idempotence(args_stop_simulator, caplog):
    MassPnfSim().stop_simulator(args_stop_simulator)
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Stopping pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP: {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in caplog.text
        assert "Cannot stop simulator, because it's not running" in caplog.text
        assert "Simulator successfully stopped" not in caplog.text
    caplog.clear()

def test_trigger_custom(args_trigger_custom, caplog):
    MassPnfSim().trigger_custom(args_trigger_custom)
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Triggering pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP: {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in caplog.text
        assert 'Simulator started' in caplog.text
        assert "Cannot start simulator since it's already running" not in caplog.text
    caplog.clear()

def test_stop(args_stop, caplog):
    MassPnfSim().stop(args_stop)
    for instance in range(SIM_INSTANCES):
        instance_ip_offset = instance * 16
        ip_offset = 2
        assert f'Stopping pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'PNF-Sim IP: {str(ip_address(IPSTART) + ip_offset + instance_ip_offset)}' in caplog.text
        assert f'ROP_file_creator.sh {instance} successfully killed' in caplog.text
        assert f"ROP_file_creator.sh {instance}" not in popen('ps afx').read()
    caplog.clear()

def test_stop_status(args_status, docker_containers, caplog):
    MassPnfSim().status(args_status)
    for instance in range(SIM_INSTANCES):
        assert f"{PNF_SIM_CONTAINER_NAME}{instance}" not in docker_containers
        assert 'Simulator containers are down' in caplog.text
    caplog.clear()

def test_stop_idempotence(args_stop, caplog, docker_containers):
    MassPnfSim().stop(args_stop)
    for instance in range(SIM_INSTANCES):
        assert f'Stopping pnf-sim-lw-{instance} instance:' in caplog.text
        assert f'ROP_file_creator.sh {instance} already not running' in caplog.text
        assert 'Simulator containers are already down' in caplog.text
        assert f"ROP_file_creator.sh {instance}" not in popen('ps afx').read()
        assert f"{PNF_SIM_CONTAINER_NAME}{instance}" not in docker_containers
    caplog.clear()

def test_clean(args_clean):
    m = MassPnfSim()
    m.clean(args_clean)
    assert not glob(f"{m.sim_dirname_pattern}*")
