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
    @topic = params[:topic]
    @comment = params[:comment]
    redirect("/")
  end


  get '/read/:topic' do
    erb :read
  end
end