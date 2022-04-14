$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'status_api_acceptance_test_helper/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'status-api-acceptance-test-helper'
  s.version     = StatusApiAcceptanceTestHelper::VERSION
  s.authors     = ['no-term-limits']
  s.email       = ['no-term-limits@example.com']
  s.summary     = 'status_api_acceptance_test_helper'
  s.description = 'status_api_acceptance_test_helper'
  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']
end
