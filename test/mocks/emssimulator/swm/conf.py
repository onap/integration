#!/usr/bin/python

import sys

SWM_DIR = sys.path[0]

NE_INFO_TABLE = SWM_DIR + "/ems_db/ne_info_table.json"
SW_SERVER_SIMULATOR = SWM_DIR + "/sw_server_simulator"
PNF_SIMULATORS_DIR = SWM_DIR + "/pnf_simulators"
PNF_SW_DOWNLOAD_DIR = "/opt/download"
PNF_SW_INSTALL_DIR = "/opt/install"
PNF_SW_FALLBACK_DIR = "/opt/fallback"
MANIFEST_FILE = "manifest.json"
INSTALLED_SW = "installed_sw.json"
CURRENT_VERSION_DIR = "current"
NOTIFICATION_DIR = "/tmp"

MAX_INT = (2**32) - 1

STATUS_DOWNLOADING = "Downloading"
STATUS_INSTALLING = "Installing"
STATUS_ACTIVATING = "Activating"
STATUS_ACTIVATED = "Activated"

STATUS_PRECHECKED = "PreChecked"
STATUS_POSTCHECKED = "PostChecked"

REQ_SUCCESS = "requestAccepted"
REQ_FAILURE = "requestFailed"

RET_CODE_SUCCESS = 0
RET_CODE_FAILURE = 1

RESULT_SUCCESS = "Success"
RESULT_FAILURE = "Failure"
RESULT_PARTLY = "Partly successful"
