# frozen_string_literal: true

RSpec.shared_examples 'status_api' do |options|
  let(:status_api_base) { "#{options[:app_url]}#{options[:path]}" }

  it 'responds to path' do
    request_headers = {} # for now
    response = rest_client_get(status_api_base, request_headers)
    expect(response.code).to eq(200)
  end
end
