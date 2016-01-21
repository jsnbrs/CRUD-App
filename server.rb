require "sinatra/base"
require 'pg'
require 'bcrypt'
require 'pry'

class Server < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/comment' do
    erb :post
  end

  post '/comment' do
    "Hello World"
  end


  get '/read' do
    erb :read
  end
end