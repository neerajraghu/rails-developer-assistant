class ChatbotService
  NOT_FOUND_MESSAGE = "I don't have information on that in my knowledge base yet. " \
                      "Try asking about ActiveRecord, associations, validations, " \
                      "migrations, controllers, routing, service objects, testing, " \
                      "or N+1 queries.".freeze

  def ask(question)
    user_message = Message.create!(role: "user", content: question)
    assistant_message = Message.create!(role: "assistant", content: answer_for(question))
    [user_message, assistant_message]
  end

  private

  def answer_for(question)
    document = KnowledgeRetrievalService.new.call(question)
    return NOT_FOUND_MESSAGE unless document

    generated_answer(question, document) || raw_document_answer(document)
  end

  def generated_answer(question, document)
    AnswerGenerationService.new.call(question: question, document: document)
  end

  def raw_document_answer(document)
    "**#{document.title}**\n\n#{document.content}"
  end
end
