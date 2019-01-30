require 'rubygems'
require 'sinatra'
require 'haml'

set :bind=>'0.0.0.0'
disable :logging

before do
  cache_control :public, :must_revalidate, :max_age => 60
end

get '/' do
	@activeTab='root'
	haml :index
end

get '/about' do
	@activeTab='about'
	haml :about
end

get '/civic' do
	haml :civic
end

not_found do
  haml :'404'
end

error do
  @e = request.env['sinatra_error']
  haml :'500'
end