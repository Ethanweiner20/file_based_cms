require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

configure do
  enable :sessions
  set :session_secret, "secret"
end

# HELPERS

# data_path : _ -> String
# Retrieves the path where data is stored, dependent on environment
def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path('test/data', __dir__)
  else
    File.expand_path('data', __dir__)
  end
end

def file_path(file_name)
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

# ROUTES

# Render home page
get '/' do
  @files = load_files
  erb :home
end

# Add new file
get '/new' do
  erb :new_file
end

post '/create' do
  file_name = params["file-name"].strip
  if file_name.empty?
    session[:message] = "A name is required."
    status 422
    erb :new_file
  else
    File.new(file_path(file_name), 'w+')
    session[:message] = "#{file_name} has been created."
    redirect '/'
  end
end

# Render a file's content
get '/:file' do
  file_name = params[:file]
  path = file_path(file_name)

  if File.exist?(path)
    load_file_content(path)
  else
    session[:message] = "#{file_name} does not exist."
    redirect "/"
  end
end

# Render edit file form
get '/:file/edit' do
  file_name = params[:file]
  path = file_path(file_name)

  @current_content = File.read(path)

  erb :edit_file
end

# Update the file
post '/:file' do
  new_content = params["new-content"]
  file_name = params[:file]
  path = file_path(file_name)

  File.write(path, new_content)
  session[:message] = "#{file_name} has been updated."
  redirect "/"
end
