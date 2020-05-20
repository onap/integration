import MassPnfSim
import pytest

@pytest.fixture(scope="module")
def parser():
    return MassPnfSim.get_parser()

@pytest.mark.parametrize(('expect_string, cli_opts'), [
    ("bootstrap: error: the following arguments are required: --urlves, --ipfileserver, --typefileserver, --ipstart",
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

@pytest.mark.parametrize(("subcommand"), [
    'bootstrap',
    'start',
    'stop',
    'trigger',
    'status'
    ])
def test_count_option(parser, capsys, subcommand):
    try:
        parser.parse_args([subcommand, '--count'])
    except SystemExit:
        pass
    assert f"{subcommand}: error: argument --count: expected one argument" in capsys.readouterr().err

def test_empty(parser, capsys):
    try:
        parser.parse_args([])
    except SystemExit:
        pass
    assert '' is capsys.readouterr().err
    assert '' is capsys.readouterr().out
