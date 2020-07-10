#!/usr/bin/env python3
import logging.config
import os
import sys
import time

import schedule
import yaml

from app_config import pnfconfig
from pnf import PNF

log_file_path = os.path.join(os.path.dirname(__file__), 'app_config/logger_config.yaml')
with open(log_file_path, 'r') as f:
    log_cfg = yaml.safe_load(f.read())
logging.config.dictConfig(log_cfg)
logger = logging.getLogger('dev')

if __name__ == "__main__":
    try:
        schedule.every(pnfconfig.ROP).seconds.do(PNF.pm_job)
        logger.info('Starting PM scheduling job')
        while True:
            schedule.run_pending()
            time.sleep(1)
    except Exception as error:
        logger.debug(error)
        sys.exit(1)
