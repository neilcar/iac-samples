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
import random

def randomword(length):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

class SockShop(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Remote(command_executor='http://localhost:4444/wd/hub', desired_capabilities=DesiredCapabilities.CHROME)
        self.driver.implicitly_wait(6)
        # get target URL from env variable
        self.base_url = os.environ['test_url']
        self.verificationErrors = []
        self.accept_next_alert = True

    def run_newuser(self, driver):

        driver.find_element_by_link_text("Register").click()
        time.sleep(2)                 
        driver.find_element_by_id("register-first-modal").clear()
        driver.find_element_by_id("register-first-modal").send_keys("Bob")
        driver.find_element_by_id("register-last-modal").clear()
        driver.find_element_by_id("register-last-modal").send_keys("Smith")
        driver.find_element_by_id("register-email-modal").clear()
        driver.find_element_by_id("register-email-modal").send_keys("bob@smith.com")
        driver.find_element_by_id("register-password-modal").clear()
        driver.find_element_by_id("register-password-modal").send_keys("password123")
        driver.find_element_by_id("register-username-modal").click()
        driver.find_element_by_id("register-username-modal").clear()
        driver.find_element_by_id("register-username-modal").send_keys(randomword(10))
        driver.find_element_by_css_selector("#register-modal > div.modal-dialog.modal-sm > div.modal-content > div.modal-body > form > p.text-center > button.btn.btn-primary").click()
        time.sleep(3)
        driver.find_element_by_link_text("Catalogue").click()
        driver.find_element_by_xpath("//input[@value='blue']").click()
        driver.find_element_by_link_text("Apply").click()
        driver.find_element_by_link_text("Add to cart").click()
        time.sleep(2)
        driver.find_element_by_link_text("Catalogue").click()
        driver.find_element_by_xpath("//input[@value='blue']").click()
        driver.find_element_by_link_text("Apply").click()
        time.sleep(2)
        driver.find_element_by_link_text("Add to cart").click()
        # driver.find_element_by_xpath("(//a[contains(text(),'Add to cart')])[1]").click()
        time.sleep(2)
        driver.find_element_by_id("numItemsInCart").click()
        time.sleep(2)
        driver.find_element_by_link_text("Change").click()
        time.sleep(2)
        driver.find_element_by_id("form-number").clear()
        driver.find_element_by_id("form-number").send_keys("666")
        driver.find_element_by_id("form-street").clear()
        driver.find_element_by_id("form-street").send_keys("Mockingbird Lane")
        driver.find_element_by_id("form-city").clear()
        driver.find_element_by_id("form-city").send_keys("Chicago")
        driver.find_element_by_id("form-city").clear()
        driver.find_element_by_id("form-city").send_keys("Beverly Hills")
        driver.find_element_by_id("form-post-code").clear()
        driver.find_element_by_id("form-post-code").send_keys("90210")
        driver.find_element_by_id("form-country").clear()
        driver.find_element_by_id("form-country").send_keys("USA")
        driver.find_element_by_css_selector("#form-address > p.text-center > button.btn.btn-primary").click()
        time.sleep(2)
        driver.find_element_by_xpath("(//a[contains(text(),'Change')])[2]").click()
        time.sleep(2)
        driver.find_element_by_id("form-card-number").clear()
        driver.find_element_by_id("form-card-number").send_keys("123456789012")
        driver.find_element_by_id("form-expires").clear()
        driver.find_element_by_id("form-expires").send_keys("0999")
        driver.find_element_by_id("form-ccv").clear()
        driver.find_element_by_id("form-ccv").send_keys("123")
        driver.find_element_by_css_selector("p.text-right > button.btn.btn-primary").click()
        time.sleep(2)
        driver.find_element_by_id("orderButton").click()
        driver.find_element_by_link_text("Home").click()
        driver.find_element_by_link_text("Logout").click()


    def run_user1(self, driver):
        time.sleep(2)
        driver.find_element_by_link_text("Login").click()
        time.sleep(2)
        driver.find_element_by_id("username-modal").clear()
        driver.find_element_by_id("username-modal").send_keys("user1")
        driver.find_element_by_id("password-modal").clear()
        driver.find_element_by_id("password-modal").send_keys("password")
        driver.find_element_by_css_selector("button.btn.btn-primary").click()            
        time.sleep(2)
        driver.find_element_by_link_text("Catalogue").click()
        # driver.find_element_by_xpath("//input[@value='blue']").click()
        driver.find_element_by_link_text("Colourful").click()
        time.sleep(2)
        driver.find_element_by_link_text("Add to cart").click()
        time.sleep(2)
        driver.find_element_by_id("numItemsInCart").click()
        time.sleep(2)
        driver.find_element_by_link_text("Change").click()
        time.sleep(2)
        driver.find_element_by_id("form-number").clear()
        driver.find_element_by_id("form-number").send_keys("666")
        driver.find_element_by_id("form-street").clear()
        driver.find_element_by_id("form-street").send_keys("Mockingbird Lane")
        driver.find_element_by_id("form-city").clear()
        driver.find_element_by_id("form-city").send_keys("Chicago")
        driver.find_element_by_id("form-city").clear()
        driver.find_element_by_id("form-city").send_keys("Beverly Hills")
        driver.find_element_by_id("form-post-code").clear()
        driver.find_element_by_id("form-post-code").send_keys("90210")
        driver.find_element_by_id("form-country").clear()
        driver.find_element_by_id("form-country").send_keys("USA")
        driver.find_element_by_css_selector("#form-address > p.text-center > button.btn.btn-primary").click()
        time.sleep(2)
        driver.find_element_by_xpath("(//a[contains(text(),'Change')])[2]").click()
        time.sleep(2)
        driver.find_element_by_id("form-card-number").clear()
        driver.find_element_by_id("form-card-number").send_keys("123456789012")
        driver.find_element_by_id("form-expires").clear()
        driver.find_element_by_id("form-expires").send_keys("0999")
        driver.find_element_by_id("form-ccv").clear()
        driver.find_element_by_id("form-ccv").send_keys("123")
        driver.find_element_by_css_selector("p.text-right > button.btn.btn-primary").click()
        time.sleep(2)
        driver.find_element_by_id("orderButton").click()
        driver.find_element_by_link_text("Logout").click()

    def test_sock_shop(self):
        try:
            driver = self.driver
            driver.get(self.base_url + "/")
            driver.implicitly_wait(10)

            for x in xrange(0, 3):

                try:
                    driver.get(self.base_url + "/")
                    self.run_user1(driver)
                
                except Exception as e:
                    exc_type, exc_obj, exc_tb = sys.exc_info()
                    fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                    print exc_tb.tb_lineno
                    print e
                    now = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
                    driver.get_screenshot_as_file('/opt/selenium-screenshots/screenshot-user1-%s.png' % now)
                    continue

                try:
                    driver.get(self.base_url + "/")
                    self.run_newuser(driver)
                    # driver.get(self.base_url + "/")
                    # self.run_user1(driver)
                
                except Exception as e:
                    exc_type, exc_obj, exc_tb = sys.exc_info()
                    fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                    print exc_tb.tb_lineno
                    print e
                    now = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
                    driver.get_screenshot_as_file('/opt/selenium-screenshots/screenshot-newuser-%s.png' % now)
                    continue

                break

        except Exception as e:
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print exc_tb.tb_lineno
            print e
            now = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
            driver.get_screenshot_as_file('/opt/selenium-screenshots/screenshot-%s.png' % now)

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
        if sys.exc_info()[0]:  # Returns the info of exception being handled 
            fail_url = self.driver.current_url
            print fail_url
            now = datetime.now().strftime('%Y-%m-%d_%H-%M-%S-%f')
            self.driver.get_screenshot_as_file('/opt/selenium-screenshots/%s.png' % now) 
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()

