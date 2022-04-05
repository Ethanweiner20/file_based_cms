require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'
require 'yaml'

configure do
  enable :sessions
  set :session_secret, "secret"
end

# HELPERS

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path('test/data', __dir__)
  else
    File.expand_path('data', __dir__)
  end
end

def load_user_credentials
  is_test = ENV["RACK_ENV"] == "test"
  prefix = is_test ? 'test/' : ''
  credentials_path = File.expand_path("#{prefix}config/users.yml", __dir__)
  YAML.load_file(credentials_path)
end

def document_path(file_name)
  File.join(data_path, file_name)
end

def load_files
  Dir.glob(File.join(data_path, "*")).map { |path| File.basename(path) }
end

def load_file_content(path)
  extension = File.extname(path)
  content = File.read(path)

  case extension
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    erb render_markdown(content)
  end
end

def render_markdown(content)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(content)
end

def authenticated?
  session.key?(:user)
end

# valid_credentials? : String String -> Boolean
# Do the credentials point to a valid user or administrator?
def valid_credentials?(username, password)
  users = load_user_credentials
  users.key?(username) && users[username] == password
end

# authenticate
# Short circuit a route if the user is not authenticated
def authenticate
  unless authenticated?
    session[:message] = "You must be signed in to do that."
    redirect '/'
  end
end

# ROUTES

# Render home page
get '/' do
  @files = load_files
  erb :home
end

# Authentication
get '/users/signin' do
  erb :signin
end

post '/users/signin' do
  username = params[:username]
  password = params[:password]

  if valid_credentials?(username, password)
    session[:user] = username
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid Credentials"
    status 422
    erb :signin
  end
end

post '/users/signout' do
  session.delete(:user)
  session[:message] = "You have been signed out."
  redirect '/'
end

# Add new file
get '/new' do
  authenticate

  erb :new_file
end

post '/create' do
  authenticate

  file_name = params["file-name"].strip
  if file_name.empty?
    session[:message] = "A name is required."
    status 422
    erb :new_file
  else
    File.new(document_path(file_name), 'w+')
    session[:message] = "#{file_name} has been created."
    redirect '/'
  end
end

# Delete a file
post '/:file/delete' do
  authenticate

  file_name = params["file"]
  File.delete(document_path(file_name))
  session[:message] = "#{file_name} was deleted."
  redirect '/'
end

# Render a file's content
get '/:file' do
  file_name = params[:file]
  path = document_path(file_name)

  if File.exist?(path)
    load_file_content(path)
  else
    session[:message] = "#{file_name} does not exist."
    redirect "/"
  end
end

# Render edit file form
get '/:file/edit' do
  authenticate

  file_name = params[:file]
  path = document_path(file_name)

  @current_content = File.read(path)

  erb :edit_file
end

# Update the file
post '/:file' do
  authenticate

  new_content = params["new-content"]
  file_name = params[:file]
  path = document_path(file_name)

  File.write(path, new_content)
  session[:message] = "#{file_name} has been updated."
  redirect "/"
end
