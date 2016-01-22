require "sinatra/base"
require 'pg'
require 'bcrypt'
require 'pry'
# require 'redcarpet'

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

    redirect("/show_all_posts")
  end

  get '/show_all_posts' do
    db = db_connect
    id = params[:id]

    @posts = db.exec("SELECT * FROM posts").to_a
    @added_comments = db.exec("SELECT * FROM comments").to_a
# "SELECT posts.*, comments.user_id AS commentor_id, comments.comment, comments.post_id FROM posts, comments WHERE posts.id = comments.post_id"
    p @added_comments
    erb :show_all_posts
  end

  get '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i
    # db.exec("SELECT * FROM posts WHERE id = #{params["id"].to_i}").first
    @comment = db.exec("SELECT title, post FROM posts WHERE (id = $1)", [id]).first
    erb :add_comment
  end

  delete '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i

    db.exec_params("DELETE FROM comments WHERE (post_id = $1)", [id])
    db.exec_params("DELETE FROM posts WHERE (id = $1)", [id])

    redirect('/show_all_posts')
  end

  get '/show_all_posts/:id/add_comment/' do
      erb :add_comment
  end

  post '/show_all_posts/:id/add_comment/' do
    db = db_connect
    add_new_comment = params[:add_new_comment]
    id = params[:id]

    @new_post = db.exec_params("INSERT INTO comments (comment, post_id) VALUES ($1, $2)", [add_new_comment, id])

    redirect("/show_all_posts")
  end

  def db_connect
    PG.connect(dbname: "forum")
  end

end