ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "rack/test"
require "fileutils"

require_relative '../cms'

class CMSTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  # Home Page

  def test_index
    create_document("about.txt")
    create_document("changes.txt")

    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    body = last_response.body
    assert_includes body, "about.txt"
    assert_includes body, "changes.txt"
  end

  # Document Viewing

  def test_viewing_text_document
    create_document("history.txt", "History!")

    get "/history.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_equal "History!", last_response.body
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

  def test_markdown_file
    create_document("about.md", "# ABOUT")
    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>ABOUT</h1>"
  end

  # Document Editing

  def test_editing_file
    create_document("about.txt", "About")

    get "/about.txt/edit"

    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, "About"
  end

  def test_file_update
    # Note: This works, even with nonexistent files
    # Logical bug: File updates allow for file creation
    post "/about.txt", "new-content" => "New About Content!"
    assert_equal "New About Content!", File.read(file_path("about.txt"))
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "about.txt has been updated."

    get "/about.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "New About Content!"
  end

  # Document Creation
  def test_new_document_form
    get "/new"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
  end

  def test_empty_name_creation
    post "/create", "file-name" => ""

    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required."

    post "/create", "file-name" => "     "

    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required."
  end

  def test_document_creation
    post "/create", "file-name" => "new_doc.txt"

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "new_doc.txt has been created"
    assert_includes last_response.body, "new_doc.txt"
  end

  def test_document_creation_with_whitespace
    post "/create", "file-name" => "   new_doc1.txt  "
    assert_equal 302, last_response.status

    get last_response["Location"] # Back to index
    assert_includes last_response.body, "new_doc1.txt has been created"

    get '/' # Remove message
    assert_includes last_response.body, "new_doc1.txt"
  end

  def test_document_deletion
    create_document("about.txt", "About")

    post "/about.txt/delete"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "about.txt was deleted."

    get '/' # Remove message
    refute_includes last_response.body, 'about.txt'
  end
end
