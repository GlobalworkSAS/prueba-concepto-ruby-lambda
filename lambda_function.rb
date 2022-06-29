# docker run --rm -v "$PWD":/var/task --mount type=tmpfs,target=/dev/shm,readonly=true lambci/lambda:ruby2.7 lambda_function.lambda_handler

require 'json'
require 'selenium-webdriver'

def lambda_handler(event:, context:)
  driver = setup_driver
  driver.navigate.to 'http://www.google.com'
  element = driver.find_element(name: 'q')
  element.send_keys 'Pizza'
  element.submit
  title = driver.title
  driver.quit
  { statusCode: 200, body: JSON.generate(title) }
end

def setup_driver
  service = Selenium::WebDriver::Service.chrome(path: '/usr/bin/chromedriver')
  Selenium::WebDriver.for :chrome, service: service, options: driver_options
end

def driver_options
  options = Selenium::WebDriver::Chrome::Options.new(binary: '/usr/bin/google-chrome')
  options.add_argument('--headless')
  options.add_argument("--window-size=800,600")
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--single-process')
  options.add_argument('start-maximized')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-extensions')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--hide-scrollbars')
  return options
end
