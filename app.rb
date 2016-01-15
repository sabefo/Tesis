configure do
  require "yaml"
  require 'mongo'
  require_relative "extend_string"

  # client = MongoClient.new # defaults to localhost:27017 db = client[‘example-db’] coll = db[‘example-collection’]

  # mongohq_url = "mongodb://heroku:6YkORCReM9hLPQNEf9UZLNmsjelu0J23HlA2NZqALDKOZRDjI0V3BLIO9-DVZxi2OB6fayAROUOo6q_BnKM8WQ@candidate.6.mongolayer.com:10581,candidate.45.mongolayer.com:10746/app40655174"
  # client = Mongo::Client.new(mongohq_url, :database => "app40655174")
  twitter = TweetStream::Client.new

end

get "/" do

end


EM.run {
  puts "entramos al event machine"

  mongohq_url = "mongodb://heroku:6YkORCReM9hLPQNEf9UZLNmsjelu0J23HlA2NZqALDKOZRDjI0V3BLIO9-DVZxi2OB6fayAROUOo6q_BnKM8WQ@candidate.6.mongolayer.com:10581,candidate.45.mongolayer.com:10746"
  client = Mongo::Client.new(mongohq_url, :database => "app40655174")
  yaml = YAML.load_file("keys.yml")

  twitter = TweetStream.configure do |config|
    config.consumer_key       = yaml["consumer_key"]
    config.consumer_secret    = yaml["consumer_secret"]
    config.oauth_token        = yaml["access_token"]
    config.oauth_token_secret = yaml["access_token_secret"]
    config.auth_method        = :oauth
  end

  topics = ["peso mexicano", "dolar peso", "devaluacion peso mexico", 
      "dolar yuan", "inflacion mexico", "devaluacion mexico", "exportaciones mexico",
      "importaciones mexico"]

  filters = ["peso mexico", "peso mexicano", "dolar", "devaluacion del peso", 
    "yuan", "inflacion", "devaluacion", "peso", "tipo de cambio"]
  ids = ["2935268052", "26538229", "83060037", "147446462", "209649640", 
      "119051398", "14917589", "38227815"]

  themes = topics + ids

  puts "-" * 100
  TweetStream::Client.new.filter({:track => themes}) do |object|
    tweet = object.text.removeaccents
    puts "#{tweet.inspect}"
    array_tweet = tweet.split(" ")
    passed = filters & array_tweet
    if !passed.empty?
      result = client[:tesis].insert_one(object.attrs)
      puts "LISTO!!!"
    end
  end
  # twitter.filter({:track => themes}) do |object|
  #   tweet = object.text.removeaccents
  #   filters.each do  |filter|
  #     if tweet.include?(filter)
  #       puts "LISTO!!!!"
  #       result = client[:tesis].insert_one(object.attrs)
  #     end
  #   end
  # end
}

  # TWITTER.filter(track: topics.join(","), follow: ids.join(",")) do  |object|
  #   tweet = object.text.removeaccents
  #   filters.each do  |filter|
  #     if tweet.include?(filter)
  #       result = client[:tesis].insert_one(object.attrs)
  #     end
  #   end
  # end

# EM.schedule do
  # http = EM::HttpRequest.new(STREAMING_URL).get :head => { 'Authorization' => [ TWITTER_USERNAME, TWITTER_PASSWORD ] }
  # buffer = ""
  # http.stream do |chunk|
  #   buffer += chunk
  #   while line = buffer.slice!(/.+\r?\n/)
  #     tweet = JSON.parse(line)
  #     DB['tweets'].insert(tweet) if tweet['text']
  #   end
  # end
# end
