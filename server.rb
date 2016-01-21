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

  delete '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i
    # db.exec("DELETE FROM posts, comments WHERE posts.id = comments.post_id").first
    db.exec("DELETE FROM comments WHERE post_id = #{id}; DELETE FROM posts WHERE id = #{id}")

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