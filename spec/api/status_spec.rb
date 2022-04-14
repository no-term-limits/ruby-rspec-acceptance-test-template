# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'status' do
  include_examples 'status_api', app_url: App::Config.test_target.base_url, path: '/todos'
end
