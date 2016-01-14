require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'em-http'
require 'json'
require 'mongo'
require "twitter"
require "bson"
require_relative 'app'
require_relative "extend_string"

run Sinatra::Application