require 'mongoid'
Mongoid.load!("./config/mongoid.yml", :development)

require_relative 'models/rating_question'
require_relative 'serializers/rating_question_serializer'
