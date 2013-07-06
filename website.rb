require 'rubygems'
require 'sinatra'
require 'haml'

set :bind=>'0.0.0.0'
disable :logging

get '/' do
	@activeTab='root'
	haml :index
end

get '/about' do
	@activeTab='about'
	haml :about
end

not_found do
  haml :'404'
end

error do
  @e = request.env['sinatra_error']
  haml :'500'
end