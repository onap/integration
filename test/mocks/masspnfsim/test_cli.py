import pytest
from MassPnfSim import MassPnfSim
from test_settings import SIM_INSTANCES

@pytest.mark.parametrize(('expect_string, cli_opts'), [
    ("bootstrap: error: the following arguments are required: --urlves, --ipfileserver, --typefileserver, " +\
     "--user, --password, --ipstart",
     ['bootstrap']),
    ("bootstrap: error: argument --typefileserver: invalid choice: 'dummy' (choose from 'sftp', 'ftps')",
     ['bootstrap', '--typefileserver', 'dummy']),
    ("bootstrap: error: argument --urlves: invalid_url is not a valid URL",
     ['bootstrap', '--urlves', 'invalid_url']),
    ("bootstrap: error: argument --ipstart: x.x.x.x is not a valid IP address",
     ['bootstrap', '--ipstart', 'x.x.x.x']),
    ("trigger_custom: error: the following arguments are required: --triggerstart, --triggerend",
     ['trigger_custom'])
    ])
def test_subcommands(parser, capsys, expect_string, cli_opts):
    try:
        parser.parse_args(cli_opts)
    except SystemExit:
        pass
    assert expect_string in capsys.readouterr().err

def test_validate_trigger_custom(parser, caplog):
    args = parser.parse_args(['trigger_custom', '--triggerstart', '0',
                             '--triggerend', str(SIM_INSTANCES)])
    try:
        MassPnfSim().trigger_custom(args)
    except SystemExit as e:
        assert e.code == 1
    assert "--triggerend value greater than existing instance count" in caplog.text
    caplog.clear()

@pytest.mark.parametrize(("subcommand"), [
    'bootstrap',
    'start',
    'stop',
    'trigger',
    'status',
    'stop_simulator'
    ])
def test_count_option(parser, capsys, subcommand):
    '''Test case where no arg passed to '--count' opt'''
    try:
        parser.parse_args([subcommand, '--count'])
    except SystemExit:
        pass
    assert f"{subcommand}: error: argument --count: expected one argument" in capsys.readouterr().err

@pytest.mark.parametrize(("subcommand"), [
    'start',
    'stop',
    'trigger',
    'status',
    'stop_simulator'
    ])
def test_count_option_bad_value(parser, caplog, subcommand):
    '''Test case where invalid value passed to '--count' opt'''
    try:
        args = parser.parse_args([subcommand, '--count', str(SIM_INSTANCES + 1)])
        m = getattr(MassPnfSim(), subcommand)
        m(args)
    except SystemExit:
        pass
    assert '--count value greater that existing instance count' in caplog.text
    caplog.clear()

def test_empty(parser, capsys):
    try:
        parser.parse_args([])
    except SystemExit:
        pass
    assert '' is capsys.readouterr().err
    assert '' is capsys.readouterr().out
