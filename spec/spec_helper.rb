# frozen_string_literal: true

RUBY_RSPEC_ACCEPTANCE_TEST_ROOT = File.expand_path('../../', Pathname.new(__FILE__).realpath)

# initialize bundler
require 'pathname'
ENV['BUNDLE_GEMFILE'] ||= File.join(RUBY_RSPEC_ACCEPTANCE_TEST_ROOT, 'Gemfile')
require 'rubygems'
require 'bundler/setup'
Bundler.require

# require gems every test must have
require 'active_support/all'

# require and include local modules every test depends on.
# we might consider not including these methods in the global namespace
require 'support/app'
require 'support/app_helper'
require 'support/rest_client_helper'
require 'support/debug_logging_helper'
require 'support/hash_extensions'

require 'status_api_acceptance_test_helper'

require 'timeout'
TEST_TIMEOUT_SECONDS = 180

class StatusFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed

  def initialize(out)
    @out = out
  end

  def example_finished(notification)
    example = notification.example
    test_result = example.execution_result.status
    return unless test_result == :failed

    example.metadata[:extra_failure_lines] ||= []
    example.metadata[:extra_failure_lines] += DebugLogging.debug_log_array
  end

  alias example_passed example_finished
  alias example_pending example_finished
  alias example_failed example_finished
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include AppHelper
  config.include RestClientHelper
  config.include FactoryBot::Syntax::Methods
  config.add_formatter StatusFormatter

  config.before(:each) do
    DebugLogging.clear_logs
  end

  config.around(:each) do |example|
    # if a test takes ridiculously long, consider it broken
    Timeout.timeout(TEST_TIMEOUT_SECONDS) { example.run }
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  # uncomment if mocks are desired
  # config.mock_with :rspec do |mocks|
  #   # Prevents you from mocking or stubbing a method that does not exist on
  #   # a real object. This is generally recommended, and will default to
  #   # `true` in RSpec 4.
  #   mocks.verify_partial_doubles = true
  # end

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
