require 'rubygems'
require 'sinatra'
require 'haml'

set :bind, '0.0.0.0'
enable :logging
@email = 'roar109@rageco.info'

get '/' do
	@activeTab='root'
	haml :index
end

get '/about' do
	@activeTab='about'
	haml :about
end