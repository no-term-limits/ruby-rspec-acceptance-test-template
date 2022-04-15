# frozen_string_literal: true

require 'yaml'

class App
  class Config
    CONFIG_FILE = File.join(RUBY_RSPEC_ACCEPTANCE_TEST_ROOT, 'config.yml')

    # rubocop:disable Style/IfUnlessModifier
    unless defined?(CONFIG)
      CONFIG = YAML.safe_load(ERB.new(File.read(CONFIG_FILE)).result, aliases: true)
    end
    # rubocop:enable Style/IfUnlessModifier

    class << self
      def get(key)
        env_config = config_with_environment[key.to_s]
        if env_config.is_a?(Hash)
          RecursiveOpenStruct.new(config_with_environment[key.to_s], recurse_over_arrays: true)
        else
          env_config
        end
      end

      def method_missing(method, *args)
        if config_with_environment.key?(method.to_s)
          get(method)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        config_with_environment.key?(method_name.to_s) || super
      end

      private

      def config_with_environment
        @config_with_environment ||= CONFIG.merge(environment_config)
      end

      def environment_config
        CONFIG[specified_environment] || raise("Cannot find the specified environment in #{CONFIG_FILE}: #{specified_environment.inspect}")
      end

      def specified_environment
        return ENV['TEST_ENV'] if ENV['TEST_ENV'].present?
        return CONFIG['default_test_environment'] if CONFIG_FILE['default_test_environment'].present?
        'default'
      end
    end
  end

  class Data
    YAML_FILES = Dir.glob(File.join(RUBY_RSPEC_ACCEPTANCE_TEST_ROOT, 'data/**/*.yml'))
    YAML_BLOB = YAML_FILES.map { |yaml_file| IO.read(yaml_file) }.join("\n")
    DATA = (YAML_BLOB.blank? ? nil : YAML.load_stream(YAML_BLOB).last.deep_symbolize_keys) unless defined? DATA

    class << self
      def get(key)
        RecursiveOpenStruct.new(DATA[key.to_sym], recurse_over_arrays: true)
      end

      def method_missing(method, *args)
        if DATA.key?(method.to_sym)
          get(method)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        DATA.key?(method.to_sym) || super
      end
    end
  end
end
