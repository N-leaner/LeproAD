#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:lepro.db"

class User < ActiveRecord::Base
	has_many :posts
	validates :name, presence: true, length: { in: 1..50 }, uniqueness: { message: "%{value} already exists" } 
	validates :password, presence: true, length: { in: 3..20 }
end	

class Post < ActiveRecord::Base
	has_many :comments
	validates :post, presence: true, length: { in: 1..500 }
end	

class Comment < ActiveRecord::Base
	belongs_to :user
	validates :comment, presence: true, length: { in: 1..500 }
end	

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login)
  end
end

get '/' do	
	#@posts = Post.order 'created_at desc'	
	@posts = User.select('users.name, posts.*').joins(:posts).order('created_at desc')		
	erb :index
end

get '/register' do
  erb :register
end

get '/login' do
  erb :login
end

get '/logout' do
  session.delete(:identity)
  @done = "Logged out"
  redirect to '/'
end

get '/secure/:id' do
	if params[:id] == 'post'
		erb :new
	elsif params[:id] == 'users'
		@users = User.all
		erb :list
	else	
		#if params[:id].include? '/comments/'	

		#end	
	end	
end	

get '/secure/comments/:post_id' do	
	#@post = Post.find_by id: post_id
	@post = User.select('users.name, posts.*').joins(:posts).where('posts.id = ?',params[:post_id]) 	
	@comments = Comment.where('comments.post_id = ?',params[:post_id])
	if @post.size == 0
		@error = "Page /comments/#{post_id} not found"
		redirect to '/'		
	else
		@post = @post[0]
		erb :comments		
	end	
end

def find_user user, autority = ''
	us = User.find_by name: user
	if us
		if autority != ''
			if us.password != autority						
  				us = nil		
			end
		end 										
	end	
	return us
end	

post '/login' do
	@user = params[:user].strip
	password = params[:password].strip

	@error = ''
	if @user == ''
		@error = 'login should not be blank'
	else
		if password == ''		
			@error = 'password should not be blank'
		end
	end	

	if @error == ''
		us = find_user @user, password
		if us 
			@done = "You`re logged in"
			session[:identity] = @user
	  		#where_user_came_from = session[:previous_url] || '/'
	  		#redirect to where_user_came_from
	  		redirect to '/'
	  	else
	  		@error = "user #{@user} not logged"
		end				
	end	

  erb :login
end

post '/register' do	
	@us = User.new params[:user]

	if @us.save
		@done = "Thank`s, #{@us.name}"
		session[:identity] = @us.name
		redirect to '/'
	else
		#'Ошибка записи - одно из полей не заполнено'
		@error = @us.errors.full_messages.first
	end	
  erb :register
end

post '/secure/post' do
	if username == ''
		return erb 'You`re not logged in!'	
	end	
	cont = params[:content].strip
	autor = find_user username
	post = autor.posts.new
	post.post = cont

	if post.save
		@done = "Thank`s, #{autor.name}, you post accepted"
	else
		#'Ошибка записи - одно из полей не заполнено'
		@error = post.errors.full_messages.first
	end	  
	
	erb 'That`s fine!'
end	

post '/secure/comments/:post_id' do

	if username == ''
		return erb 'You`re not logged in!'	
	end	
	comment = params[:comment].strip
	autor = find_user username
	post = Post.find_by id: params[:post_id]
	co = post.comments.new
	co.user = autor
	co.comment = comment

	if co.save
		@done = "Thank`s, #{autor.name}, you comment accepted"
	else
		#'Ошибка записи - одно из полей не заполнено'
		@error = co.errors.full_messages.first
	end	  
	
	@post = User.select('users.name, posts.*').joins(:posts).where('posts.id = ?',params[:post_id]) 	
	@comments = Comment.where('comments.post_id = ?',params[:post_id])
	if @post.size >= 0		
		@post = @post[0]		
	end

	erb :comments
end	