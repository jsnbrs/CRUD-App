require 'sinatra/base'
require 'pg'
require 'bcrypt'
require 'pry'
require 'redcarpet'

ERRORS = {
  "1" => "User already exists. Please use a different email.",
  "2" => "poop"
}

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
    @error = ERRORS[ params[:e] ]
    erb :signup
  end

  post '/signup' do
    db = db_connect

    name = params[:name]
    email = params[:email]
    password_bcrypt = BCrypt::Password.create(params[:login_password])

    begin
      new_user = db.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id", [name, email, password_bcrypt])
    rescue
      redirect('/signup?e=1')
    end

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

    if @user
      if BCrypt::Password.new(@user['password']) == params[:login_password]
        session['user_id'] = @user['id']
        redirect('/show_all_posts')
      else
        ############################################################################################ consider a redirect
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
    erb :logout
  end
########################################### new topics

  get '/new_topic' do
    if session["user_id"]
    erb :new_topic
        else
      redirect('/login')
    end
  end

  post '/new_topic' do
    db = db_connect
    title = params[:title]

    #### Markdown ####
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    post = markdown.render(params[:new_topic])
    #### Markdown ####

    @session_user_id = session['user_id']
    @new_post = db.exec_params("INSERT INTO posts (title, post, user_id) VALUES ($1, $2, $3)", [title, post, session["user_id"]])

    redirect("/show_all_posts")
  end
########################################### view all posts

  get '/show_all_posts' do
    db = db_connect
    id = params[:id]

    @all_users = db.exec("SELECT * FROM users").to_a
    @posts = db.exec("select * from users join posts on posts.user_id = users.id").to_a
    
    @comment_count = db.exec_params("select count (post_id) from comments where (post_id = $1)", [id]).to_a
    @added_comments = db.exec("select name, comment, post_id from users join comments on comments.user_id = users.id").to_a

    if session["user_id"]
      erb :show_all_posts
    else
      redirect('/login')
    end
  end

  get '/topic_upvote/:id' do 
    db = db_connect
    id = params[:id].to_i
    db.exec_params("UPDATE posts SET upvote = upvote + 1 WHERE id = ($1)", [id])
    redirect('/show_all_posts')
  end
########################################### individual posts

  get '/show_all_posts/:id' do
    db = db_connect
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
    if session["user_id"] #### redirect here if user not logged in
      id = params[:id].to_i
      erb :add_comment
    else
      redirect('/login')
    end
  end

  post '/show_all_posts/:id/add_comment/' do
    db = db_connect
    
    #### Markdown ####
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    add_new_comment = markdown.render(params[:add_new_comment])
    #### Markdown ####

    id = params[:id].to_i
    db.exec_params("INSERT INTO comments (comment, post_id, user_id) VALUES ($1, $2, $3)", [add_new_comment, id, session["user_id"]])
    
    redirect("/show_all_posts")
  end

  get '/all_topics' do
    db = db_connect

    @order_by_upvotes = db.exec("SELECT * FROM posts ORDER BY upvote DESC").to_a
    if session["user_id"]
      erb :all_topics
    else
      redirect('/login')
    end
  end

  get '/individual_topic/:id' do
    db = db_connect
    id = params[:id].to_i
    @individual_post = db.exec_params("SELECT * FROM posts WHERE (id = $1)", [id]).to_a
    @individual_comments  = db.exec("SELECT name, comment, post_id FROM users JOIN comments ON comments.user_id = users.id WHERE (post_id = $1)", [id]).to_a
    erb :individual_topic
  end
########################################### connect to db

  def db_connect
    PG.connect(dbname: "forum")
  end
end