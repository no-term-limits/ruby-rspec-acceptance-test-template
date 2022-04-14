# frozen_string_literal: true

module AppHelper
  def config
    App::Config
  end

  def data
    App::Data
  end

  def json_to_hash(json)
    JSON.parse(json, symbolize_names: true)
  rescue StandardError => e
    puts e.inspect
  end

  def hash_for_xml(xml)
    Hash.from_xml(xml).deep_symbolize_keys
  end

  def gzip_compress(string)
    ActiveSupport::Gzip.compress(string)
  end

  def gzip_decompress(zipped_string)
    ActiveSupport::Gzip.decompress(zipped_string)
  end
end
