# ruby-rspec-acceptance-test-template

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
