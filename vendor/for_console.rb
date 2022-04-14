require 'spec_helper'

RSpec.describe 'not a test' do
  it 'is just for bin/console' do
    require 'pry'
    binding.pry
  end
end
