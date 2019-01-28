require 'sinatra'
require 'sinatra/reloader'

require_relative 'environment'

before do
  response['Access-Control-Allow-Origin'] = '*'
  content_type :json
end

def serialize_question(question)
  RatingQuestionSerializer.new(question)
end

def find_question(id)
  question = RatingQuestion.where(id: id).first

  return question if question

  # If no question, return a 404 and halt
  status 404
  halt
end

get '/ratingQuestions' do
  RatingQuestion.all.map { |question| serialize_question(question) }.to_json
end

get '/ratingQuestions/:id' do
  question = find_question(params[:id])

  serialize_question(question).to_json
end

post '/ratingQuestions' do
  body = request.body.read

  if body == ''
    status 400
    return
  end

  json_params = JSON.parse(body)

  rating_question = RatingQuestion.new(json_params)

  if rating_question.save
    status 201
    serialize_question(rating_question).to_json
  else
    status 422
    { "errors" => rating_question.errors }.to_json
  end
end

def update
  body = request.body.read

  if body == ''
    status 400
    return
  end

  json_params = JSON.parse(body)

  question = find_question(params[:id])

  if question.update(json_params)
    return serialize_question(question).to_json
  end
end

put('/ratingQuestions/:id') { update }
patch('/ratingQuestions/:id') { update }

delete '/ratingQuestions/:id' do
  question = find_question(params[:id])

  question.destroy
  status 204
end
