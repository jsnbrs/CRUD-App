require "sinatra/base"
require 'pg'
require 'bcrypt'
require 'pry'

class Server < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/post' do
    erb :post
  end

  post '/post' do
    db = db_connect
    title = params[:title]
    post = params[:post]
    "#{title}"
    "#{post}"

    @new_post = db.exec_params("INSERT INTO posts (title, post) VALUES ($1, $2)", [title, post])


    redirect("/")
  end


  get '/read/:post' do
        "#{title}"
    "#{post}"
    erb :read
  end

  private

  def db_connect
    PG.connect(dbname: "forum")
  end
end