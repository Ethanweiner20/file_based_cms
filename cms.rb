require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

# Guarantees that we access the root directory of `cms.rb`
ROOT = File.expand_path(__dir__)

def load_files
  Dir.glob("#{ROOT}/data/*").map { |path| File.basename(path) }
end

get '/' do
  @files = load_files
  erb :home
end

get '/:file' do
  file_path = "#{ROOT}/data/#{params[:file]}"
  headers["Content-Type"] = "text/plain"
  File.read(file_path)
end
