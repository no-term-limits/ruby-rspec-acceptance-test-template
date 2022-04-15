[![CI](https://github.com/no-term-limits/ruby-rspec-acceptance-test-template/actions/workflows/ci.yml/badge.svg)](https://github.com/no-term-limits/ruby-rspec-acceptance-test-template/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/tterb/atomic-design-ui/blob/master/LICENSEs)

# ruby-rspec-acceptance-test-template

This project is designed to be a jumping off point for testing webapps that you
have deployed to some environment and are available via http. It has facilities
for testing using api-based tests and browser-based tests.

## run

`bundle exec rspec`

## configs

Configs can be added to config.yml and then referenced from within spec files
like `config.config_key1.config_key2`

## test environments

Different environments can be set up from within the config dir by creating new
keys and they can inherit from the default configs.

Specify a specified environment with the TEST_ENV environment variable.

## data

Data can be added to its own yaml file in the data directory and referenced like
`data.data_key1.data_key2`

## tests

Tests can be added to the spec directory. See spec/api/todos_spec.rb as an
example

## Similar projects

 * https://github.com/brooklynDev/airborne
