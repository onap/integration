from pnf import PNF
import schedule
import pnfconfig
import time

if __name__ == "__main__":
    try:
        pnf = PNF()
        schedule.every(pnfconfig.rop).seconds.do(lambda: pnf.pmJob(pnfconfig.VES_IP,pnfconfig.VES_PORT))
        while True:
            schedule.run_pending()
            time.sleep(1)
    except Exception as e:
        print(e)