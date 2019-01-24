require 'sinatra'
require 'sinatra/reloader'

require 'json'

before do
  response['Access-Control-Allow-Origin'] = '*'
  content_type :json
end

def rating_questions
  JSON.parse(File.read('db.json'))['ratingQuestions']
end

def write_questions(questions)
  File.write("db.json", { "ratingQuestions" => questions }.to_json)
end

def find_question(id)
  rating_questions.find { |q| q["id"] == id }
end

get '/ratingQuestions' do
  rating_questions.to_json
end

get '/ratingQuestions/:id' do
  question = find_question(params[:id].to_i)
  unless question
    status 404
    return
  end

  question.to_json
end

post '/ratingQuestions' do
  body = request.body.read

  if body == ''
    status 400
    return
  end

  json_params = JSON.parse(body)

  last_id = 0 if rating_questions.none?
  last_id ||= rating_questions.max_by { |q| q["id"] }["id"]

  if json_params["title"].strip == ''
    status 422
    return { "errors" => { "title" => ["cannot be blank"] } }.to_json
  end
  new_question = {
    "id" => last_id + 1
  }.merge(json_params)

  write_questions(rating_questions.push(new_question))

  status 201
  new_question.to_json
end

def update
  body = request.body.read

  if body == ''
    status 400
    return
  end

  json_params = JSON.parse(body)

  updated_questions = rating_questions
  question = updated_questions.find { |q| q["id"] == params[:id].to_i }

  unless question
    status 404
    return
  end

  question.merge!(json_params)

  write_questions(updated_questions)

  question.to_json
end

put('/ratingQuestions/:id') { update }
patch('/ratingQuestions/:id') { update }

delete '/ratingQuestions/:id' do
  id = params[:id].to_i

  unless find_question(id)
    status 404
    return
  end

  new_questions = rating_questions.keep_if { |q| q["id"] != id }
  write_questions(new_questions)
  status 204
end
