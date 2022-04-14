# frozen_string_literal: true

require 'spec_helper'
require 'support/capybara_helper'

RSpec.describe 'browser', type: :feature, js: true do
  it 'can visit webpage' do
    visit(App::Config.test_target.base_url)
    click_on('Guide')
    expect(page).to have_content "Below you'll find examples"
  end
end
