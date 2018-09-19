require 'sinatra'
require 'redis'
require 'connection_pool'

class App < Sinatra::Base
  set :public_folder, File.dirname("__FILE__") + '/_site/'

  def initialize
    @redis = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(url: ENV['REDIS_URL']) }
    super
  end

  get "/" do
    erb :index, :layout => :home, :locals => {
      count: count,
      title: "The best daylong conference in Austin celebrating (figurative) hugs, magic, singing, & dancing!"
    }

  end

  get "/conduct" do
    erb :conduct, :locals => {
      count: count,
      title: "Code of Coduct",
    }
  end

  get "/mailing" do
    erb :mailing, :locals => {
      count: count,
      title: "Mailing List"
    }
  end

  private
  def count
    num = 0
    @redis.with do |conn|
      num = conn.incr("web_count")
    end

    array = num.to_s.split(//)
    padding = 9 - array.size
    1.upto(padding) do
      array.prepend("0")
    end

    array
  end
end
