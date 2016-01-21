require "sinatra/base"
require 'pg'
require 'bcrypt'
require 'pry'

class Server < Sinatra::Base

  set :method_override, true

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

    @new_post = db.exec_params("INSERT INTO posts (title, post) VALUES ($1, $2)", [title, post])


    redirect("/")
  end


  get '/read' do
    db = db_connect

    @posts = db.exec("SELECT * FROM posts").to_a
    erb :read
  end

  delete '/read/:id' do
    db = db_connect

    db.exec("DELETE FROM posts WHERE id = #{params["id"].to_i}").first

    "Post removed!"
    redirect('/read')
  end

  def db_connect
    PG.connect(dbname: "forum")
  end
end