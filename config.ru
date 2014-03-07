require 'bundler'
Bundler.require
require 'securerandom'
require './server'
run Rack::URLMap.new '/' => Sinatra::Application