require 'tweetstream'
require "yaml"
require "mongo"
require "bson"
require_relative "extend_string"

yaml = YAML.load_file("keys.yml")

TweetStream.configure do |config|
  config.consumer_key       = yaml["consumer_key"]
  config.consumer_secret    = yaml["consumer_secret"]
  config.oauth_token        = yaml["access_token"]
  config.oauth_token_secret = yaml["access_token_secret"]
  config.auth_method        = :oauth
end

mongohq_url = "mongodb://heroku:6YkORCReM9hLPQNEf9UZLNmsjelu0J23HlA2NZqALDKOZRDjI0V3BLIO9-DVZxi2OB6fayAROUOo6q_BnKM8WQ@candidate.6.mongolayer.com:10581,candidate.45.mongolayer.com:10746/app40655174"
client = Mongo::Client.new(mongohq_url, :database => "app40655174")

topics = ["peso mexicano", "dolar peso", "devaluacion peso mexico", 
  "dolar yuan", "inflacion mexico", "devaluacion mexico", "exportaciones mexico",
  "importaciones mexico"]

filters = ["peso mexicano", "dolar", "devaluacion del peso", "yuan",
  "inflacion", "devaluacion", "peso", "tipo de cambio"]

ids = ["2935268052", "26538229", "83060037", "147446462", "209649640", 
  "119051398", "14917589", "38227815"]

themes = topics + ids

TweetStream::Client.new.filter({:track => themes}) do |object|
  tweet = object.text.removeaccents
  filters.each do  |filter|
    if tweet.include?(filter)
      result = client[:tesis].insert_one(object.attrs)
      puts "LISTO!!!!"
    end
  end
end

# i = 1
# TWITTER.filter(track: topics.join(","), follow: ids.join(",")) do |object|
#   tweet = object.text.removeaccents
#   filters.each do  |filter|
#     if tweet.include?(filter)
#       puts "#{i}- #{object.text}" if object.is_a?(Twitter::Tweet)
#       tweets.insert(object)
#       i += 1
#     end
#   end
# end
