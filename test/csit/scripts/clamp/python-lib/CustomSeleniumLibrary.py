from Selenium2Library import Selenium2Library
from selenium.webdriver.common.keys import Keys
import time

class CustomSeleniumLibrary(Selenium2Library):
    def insert_into_prompt(self, text):
        alert = None
        try:
            time.sleep(5)
            listOfFields = text.split(" ")
            allInOneString=""
            for temp in listOfFields:
               allInOneString=allInOneString+temp+Keys.TAB

            alert= self._current_browser().switch_to_alert()
            alert.send_keys(allInOneString)
        except WebDriverException:
            raise RuntimeError('There were no alert')


