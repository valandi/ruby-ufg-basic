require 'eyes_selenium'
require 'webdrivers/chromedriver'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Create a new chrome web driver
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless') if ENV['CI'] == 'true'
web_driver = Selenium::WebDriver.for :chrome, options: options

# Create a runner with concurrency of 1
visual_grid_runner = Applitools::Selenium::VisualGridRunner.new(1)

# Create Eyes object with the runner, meaning it'll be a Visual Grid eyes.
eyes = Applitools::Selenium::Eyes.new(runner: visual_grid_runner)
eyes.send_dom=true
# Initialize eyes Configuration
eyes.configure do |conf|
  #  You can get your api key from the Applitools dashboard
  conf.api_key = ENV['APPLITOOLS_API_KEY']
  # create a new batch info instance and set it to the configuration
  conf.batch = Applitools::BatchInfo.new("Demo Batch - Selenium Ruby - Ultrafast 2")
  conf.app_name = 'rca test 2'
  conf.test_name = 'rca test 2'
  conf.viewport_size = Applitools::RectangleSize.new(800, 600)
  # Add browsers with different viewports
  conf.add_browser(800, 600, BrowserType::CHROME)
      .add_browser(700, 500, BrowserType::FIREFOX)
      .add_browser(800,600, BrowserType::SAFARI)
      .add_browser(1600,1200, BrowserType::IE_11)
      .add_browser(1024,768, BrowserType::EDGE_CHROMIUM)
  #  Add mobile emulation devices in Portrait mode
  conf.add_device_emulation(Devices::IPhoneX, Orientation::PORTRAIT)
      .add_device_emulation(Devices::Pixel2, Orientation::PORTRAIT)
end

 # ⭐️ Note to see visual bugs, run the test using the above URL for the 1st run.
 # but then change the above URL to https://demo.applitools.com/index_v2.html
 # (for the 2nd run)
begin

  # Call Open on eyes to initialize a test session
  driver = eyes.open(driver: web_driver)

  # Navigate to the url we want to test
  driver.get('https://demo.applitools.com/index.html')

  # check the login page with fluent api, see more info here
  # https://applitools.com/docs/topics/sdk/the-eyes-sdk-check-fluent-api.html
  eyes.check('Login page', Applitools::Selenium::Target.window.fully)

  # Click the 'Log In' button
  driver.find_element(:id, 'log-in').click

  # Check the app page
  eyes.check('App Page', Applitools::Selenium::Target.window.fully)

  # Call Close on eyes to let the server know it should display the results
  eyes.close
ensure
  # Close the browser
  driver.quit
  # If the test was aborted before eyes.close / eyes.close_async was called, ends the test as aborted.
  eyes.abort_async

  # we pass false to this method to suppress the exception that is thrown if we
  # find visual differences
  results = visual_grid_runner.get_all_test_results
  puts results
end


