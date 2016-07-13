#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:lepro.db"

class User < ActiveRecord::Base
	has_many :posts
	validates :name, presence: true, length: { in: 1..50 }
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

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end