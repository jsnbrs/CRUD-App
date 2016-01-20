class Server < Sinatra::Base

  get '/' do
    redirect "/index"
  end

  get '/index' do
    erb :index
  end

  get '/post' do
    erb :post
  end

  get '/read' do
    erb :read
  end
end