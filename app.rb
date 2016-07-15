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
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
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
  erb "Have a nice day!"
end

get '/secure/:id' do
	if params[:id] == 'post'
	elsif params[:id] == 'users'
				
	end	

end	

post '/register' do
	@us = User.new params[:user]

	if @us.save
		@done = "Thank`s, #{@us.name}"
	else
		#'Ошибка записи - одно из полей не заполнено'
		@error = @us.errors.full_messages.first
	end	
  erb :register
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
		#us = User.where("name = ?", user)
		us = User.find_by name: @user
		if !us
			@error = "user #{@user} not exists"
		else
			if us.password == password
				@done = "You`re logged in"
				session[:identity] = @user
  				where_user_came_from = session[:previous_url] || '/'
  				redirect to where_user_came_from
			else
				@error = "Password wrong"
			end	
		end					
	end	

  erb :login
end