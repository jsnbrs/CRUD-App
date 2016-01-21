require "sinatra/base"
require 'pg'
require 'bcrypt'
require 'pry'

class Server < Sinatra::Base

  set :method_override, true

  get '/' do
    erb :index
  end

  get '/new_topic' do
    erb :new_topic
  end

  post '/new_topic' do
    db = db_connect

    title = params[:title]
    post = params[:new_topic]

    @new_post = db.exec_params("INSERT INTO posts (title, post) VALUES ($1, $2)", [title, post])


    redirect("/")
  end

  get '/show_all_posts' do
    db = db_connect
    id = params[:id]

    @posts = db.exec("SELECT * FROM posts").to_a
    @added_comments = db.exec("SELECT comment FROM comments").to_a
    # WHERE post_id = '#{id}'
    p @added_comments
    erb :show_all_posts
  end

  delete '/show_all_posts/:id' do
    db = db_connect

    db.exec("DELETE FROM posts WHERE id = #{params["id"].to_i}").first

    "Post removed!"
    redirect('/show_all_posts')
  end

  get '/show_all_posts/:id' do
    db = db_connect

    db.exec("SELECT * FROM posts WHERE id = #{params["id"].to_i}").first
    @comment = db.exec("SELECT title, post FROM posts WHERE id = #{params["id"].to_i}").first
    erb :add_comment
  end

  get '/show_all_posts/:id/add_comment/' do
      erb :add_comment
  end

  post '/show_all_posts/:id/add_comment/' do
    db = db_connect
    comment = params[:new_topic]
    id = params[:id]

    @new_post = db.exec_params("INSERT INTO comments (comment, post_id) VALUES ($1, $2)", [comment, id])


    redirect("/show_all_posts")
  end

  def db_connect
    PG.connect(dbname: "forum")
  end

end