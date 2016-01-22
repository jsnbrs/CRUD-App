require 'sinatra/base'
require 'pg'
require 'bcrypt'
require 'pry'
# require 'redcarpet'

class Server < Sinatra::Base

  enable :sessions
  set :method_override, true

########################################### current user
  def current_user
    db = db_connect

    if session['user_id']
    @current_user ||= db.exec_params("SELECT * FROM users WHERE (id = $1)", [session['user_id']]).first
    else
      {}
    end
  end

  get '/' do
    erb :index
  end
########################################### signup
  get '/signup' do
    erb :signup
  end

  post '/signup' do
    db = db_connect

    name = params[:name]
    email = params[:email]
    password_bcrypt = BCrypt::Password.create(params[:login_password])
    new_user = db.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id", [name, email, password_bcrypt])

    session['user_id'] = new_user.first['id'].to_i

    erb :signup_success
  end
########################################### login
  get '/login' do
    erb :login
  end

  post '/login' do
    db = db_connect
    email = params[:email]
    @user = db.exec_params("SELECT * FROM users WHERE email = $1", [email]).first

    # @user = db.exec_params("SELECT * FROM users WHERE name = $1", [params[:name]]).first
p @user
    if @user
      if BCrypt::Password.new(@user['password']) == params[:login_password]
        session['user_id'] == @user['id']
        redirect '/'
      else
        @error_password = "Your password isn't working."
        erb :login
      end
    else
      @error_email = "That email isn't working."
      erb :login
    end
  end
########################################### log out
  get '/logout' do
    session['user_id'] = nil
    flash[:notice] = "You have logged out."
    redirect '/'
  end
########################################### new topics
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
########################################### view all posts
  get '/show_all_posts' do
    db = db_connect
    id = params[:id]

    @posts = db.exec("SELECT * FROM posts").to_a
    @added_comments = db.exec("SELECT * FROM comments").to_a
# "SELECT posts.*, comments.user_id AS commentor_id, comments.comment, comments.post_id FROM posts, comments WHERE posts.id = comments.post_id"
    p @added_comments
    erb :show_all_posts
  end
########################################### individual posts
  get '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i
    # db.exec("SELECT * FROM posts WHERE id = #{params["id"].to_i}").first
    @comment = db.exec("SELECT title, post FROM posts WHERE (id = $1)", [id]).first
    erb :add_comment
  end
########################################### delete posts
  delete '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i

    db.exec_params("DELETE FROM comments WHERE (post_id = $1)", [id])
    db.exec_params("DELETE FROM posts WHERE (id = $1)", [id])

    redirect('/show_all_posts')
  end
########################################### add comment to topic
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
########################################### connect to db
  def db_connect
    PG.connect(dbname: "forum")
  end

end