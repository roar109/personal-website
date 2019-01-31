require 'rubygems'
require 'sinatra'
require 'haml'

set :bind=>'0.0.0.0'
set :port=>'80'
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

get '/status' do
	redirect '/statuspage/index.html'
end

not_found do
  haml :'404'
end

error do
  @e = request.env['sinatra_error']
  haml :'500'
end