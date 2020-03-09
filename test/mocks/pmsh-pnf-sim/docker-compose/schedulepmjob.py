#!/usr/bin/env python3

import time
import schedule
from pnf import PNF
import pnfconfig

if __name__ == "__main__":
    try:
        pnf = PNF()
        schedule.every(pnfconfig.ROP).seconds.do(pnf.pm_job)
        while True:
            schedule.run_pending()
            time.sleep(1)
    except Exception as error:
        print(error)
