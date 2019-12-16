import time
import schedule
from pnf import PNF
import pnfconfig

if __name__ == "__main__":
    try:
        pnf = PNF()
        schedule.every(pnfconfig.rop).seconds.do(lambda: pnf.pm_job(pnfconfig.VES_IP, pnfconfig.VES_PORT))
        while True:
            schedule.run_pending()
            time.sleep(1)
    except Exception as error:
        print(error)
