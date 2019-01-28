class RatingQuestionSerializer
  attr_reader :question

  def initialize(question)
    @question = question
  end

  def as_json(_)
    {
      id: question.id.to_s,
      title: question.title,
      tag: question.tag
    }
  end
end
