# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'todos', endpoint: '/todos' do
  context 'GET Request' do
    it 'fetches data', priority: 'high' do
      response = rest_client_get("#{App::Config.test_target.base_url}/todos/1")
      expect(response.code).to eq(200)
      response_hash = json_to_hash(response)
      expect(response_hash).to include(data.api.todos.expected_response_hash.to_h)
    end
  end
end
