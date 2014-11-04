#!/usr/bin/env python2

import os, sys, time, urllib2
from selenium import webdriver
from sauceclient import SauceClient

USERNAME = os.environ.get("SAUCE_USERNAME")
ACCESS_KEY = os.environ.get("SAUCE_ACCESS_KEY")
SAUCE_URL = "http://%s:%s@ondemand.saucelabs.com:80/wd/hub" % (USERNAME, ACCESS_KEY)

caps = webdriver.DesiredCapabilities.CHROME
caps["platform"] = "Windows 8.1"
caps["version"] = "30"
caps["browserName"] = "chrome"

# Add require tunnel-identifier for Travis/SauceLabs addon
caps["tunnel-identifier"] = os.environ.get("TRAVIS_JOB_NUMBER")

sauce = SauceClient(USERNAME, ACCESS_KEY)
driver = webdriver.Remote(
    command_executor=SAUCE_URL,
    desired_capabilities=caps
)
sauce.jobs.update_job(driver.session_id,
  build_num=os.environ.get("TRAVIS_BUILD_NUMBER"),
  name=os.environ.get("TRAVIS_BUILD_NUMBER"),
  custom_data=os.environ.get("TRAVIS_COMMIT")
)

driver.get(sys.argv[1])
body = driver.find_element_by_tag_name("body")
while "Tests complete. View log in console." not in body.text:
    time.sleep(10)

print "Link to your job: https://saucelabs.com/jobs/%s" % self.driver.session_id
try:
    sauce.jobs.update_job(driver.session_id, passed=True)
finally:
    driver.quit()
