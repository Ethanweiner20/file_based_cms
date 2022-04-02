require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

# Guarantees that we access the root directory of `cms.rb`
ROOT = File.expand_path(__dir__)

configure do
  enable :sessions
  set :session_secret, "secret"
end

def load_files
  Dir.glob("#{ROOT}/data/*").map { |path| File.basename(path) }
end

get '/' do
  @files = load_files
  erb :home
end

get '/:file' do
  file_path = "#{ROOT}/data/#{params[:file]}"

  if File.exist?(file_path)
    headers["Content-Type"] = "text/plain"
    File.read(file_path)
  else
    session[:message] = "#{params[:file]} does not exist."
    redirect "/"
  end
end
