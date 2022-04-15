# frozen_string_literal: true

require 'yaml'

class App
  class Config
    @config = nil
    @config_with_environment = nil

    CONFIG_FILE = File.join(RUBY_RSPEC_ACCEPTANCE_TEST_ROOT, 'config.yml') unless defined? CONFIG_FILE

    class << self
      def config
        return @config if @config

        @config = YAML.safe_load(ERB.new(File.read(CONFIG_FILE)).result, aliases: true)
      end

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
        @config_with_environment ||= config.merge(environment_config)
      end

      def environment_config
        config[specified_environment] || raise("Cannot find the specified environment in #{CONFIG_FILE}: #{specified_environment.inspect}")
      end

      def specified_environment
        return ENV['TEST_ENV'] if ENV['TEST_ENV'].present?
        return config['default_test_environment'] if config['default_test_environment'].present?

        'default'
      end
    end
  end

  class Data
    @data = nil

    class << self
      def data
        return @data if @data

        yaml_files = Dir.glob(File.join(RUBY_RSPEC_ACCEPTANCE_TEST_ROOT, 'data/**/*.yml'))
        yaml_blob = yaml_files.map { |yaml_file| File.read(yaml_file) }.join("\n")
        @data = (yaml_blob.blank? ? nil : YAML.load_stream(yaml_blob).last.deep_symbolize_keys)
      end

      def get(key)
        RecursiveOpenStruct.new(data[key.to_sym], recurse_over_arrays: true)
      end

      def method_missing(method, *args)
        if data.key?(method.to_sym)
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
