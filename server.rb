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

  get '/read/:id' do
    db = db_connect

    db.exec("SELECT * FROM posts WHERE id = #{params["id"].to_i}").first
    @comment = db.exec("SELECT title, post FROM posts WHERE id = #{params["id"].to_i}").first
    erb :add_comment
  end

  get '/read/:id/add_comment/' do
      erb :add_comment
  end

  post '/read/:id/add_comment/' do
    db = db_connect
    comment = params[:post]
    id = params[:id]

    @new_post = db.exec_params("INSERT INTO comments (comment, post_id) VALUES ($1, $2)", [comment, id])


    redirect("/read")
  end

  def db_connect
    PG.connect(dbname: "forum")
  end

end