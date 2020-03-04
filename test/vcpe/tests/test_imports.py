import sys
sys.path.append('./')

# pylint: disable=W0611
import vcpecommon
import config_sdnc_so
import csar_parser
import preload
import sdcutils
import soutils
import vcpe_custom_service
import vcpecommon

# This will test whether all modules that vcpe scripts leverage
# are included in setuptools configuration

def test_imports():
  pass
