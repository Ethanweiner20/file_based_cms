ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "rack/test"

require_relative '../cms'

ROOT = File.expand_path('..', __dir__)

class CMSTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    body = last_response.body
    assert_match(/about.txt/, body)
    assert_match(/changes.txt/, body)
    assert_match(/history.txt/, body)
  end

  def test_viewing_text_document
    get "/history.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_equal File.new("#{ROOT}/data/history.txt").read, last_response.body
  end

  def test_nonexistent_file
    nonexistent_file = "does_not_exist.txt"

    get "/#{nonexistent_file}"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "#{nonexistent_file} does not exist"

    get "/"
    refute_includes last_response.body, "#{nonexistent_file} does not exist"
  end
end
