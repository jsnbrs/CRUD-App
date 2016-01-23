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
    post = params[:new_topic]

    @session_user_id = session['user_id']

    @new_post = db.exec_params("INSERT INTO posts (title, post, user_id) VALUES ($1, $2, $3)", [title, post, session["user_id"]])

    redirect("/show_all_posts")
  end
########################################### view all posts

  get '/show_all_posts' do
    db = db_connect
    id = params[:id]

    # @posts = db.exec("SELECT * FROM posts").to_a
    @posts = db.exec("SELECT * FROM posts JOIN users ON posts.user_id = users.id")
    # @added_comments = db.exec("SELECT * FROM comments").to_a
    @added_comments = db.exec("select * from comments join users on comments.user_id = users.id")

    # figure out what data to base this decision off of
    if session["user_id"]
      erb :show_all_posts
    else
      redirect('/login')
    end
  end
########################################### individual posts

  get '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i
    # db.exec("SELECT * FROM posts WHERE id = #{params["id"].to_i}").first
    @comment = db.exec("SELECT title, post, FROM posts WHERE (id = $1)", [id]).first
    erb :add_comment
  end
########################################### delete posts

  delete '/show_all_posts/:id' do
    db = db_connect
    id = params[:id].to_i
  ################################## need to fix, just deleting all comments not posts
    db.exec_params("DELETE FROM comments WHERE (post_id = $1)", [id])
    db.exec_params("DELETE FROM posts WHERE (id = $1)", [id])

    redirect('/show_all_posts')
  end
########################################### add comment to topic

  get '/show_all_posts/:id/add_comment/' do
    if session["user_id"] #### redirect here if user not logged in
    erb :add_comment
    else
      redirect('/login')
    end
  end

  post '/show_all_posts/:id/add_comment/' do
    db = db_connect

    add_new_comment = params[:add_new_comment]
    id = params[:id]

    @new_post = db.exec_params("INSERT INTO comments (comment, post_id, user_id) VALUES ($1, $2, $3)", [add_new_comment, id, session['user_id']])

    redirect("/show_all_posts")
  end
########################################### connect to db

  def db_connect
    PG.connect(dbname: "forum")
  end

  # def markdown(markdown_comment)
  #   markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  #   markdown.render(markdown_comment)
  # end
end