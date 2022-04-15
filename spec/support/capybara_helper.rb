# frozen_string_literal: true

require 'capybara/poltergeist'
require 'capybara/cuprite'
require 'capybara/rspec'

module CapybaraHelper
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :firefox do |app|
    Capybara::Selenium::Driver.new(app, browser: :firefox)
  end

  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.args << '--headless'
    options.args << '--disable-gpu'
    options.args << '--no-sandbox'
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.register_driver :headless_firefox do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.args << '--headless'
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  end

  Capybara.register_driver :phantomjs do |app|
    options = {
      js_errors: false,
      phantomjs: Phantomjs.path,
      phantomjs_options: ['--ssl-protocol=any'],
      phantomjs_logger: File.open(File::NULL, 'w') # suppress logged messages (by default)
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end

  Capybara.register_driver :cuprite do |app|
    Capybara::Cuprite::Driver.new(app, browser_options: { 'no-sandbox': nil })
  end

  Capybara.default_driver = App::Config.capybara_driver.to_sym
  Capybara.javascript_driver = App::Config.capybara_driver.to_sym
end
