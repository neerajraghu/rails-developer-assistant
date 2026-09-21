# Orchestrates one question/answer turn: stores the user's message, searches
# the knowledge base, and stores the matching answer (or a clear "not found"
# message) as the assistant's reply.
class ChatbotService
  NOT_FOUND_MESSAGE = "I don't have information on that in my knowledge base yet. " \
                      "Try asking about ActiveRecord, associations, validations, " \
                      "migrations, controllers, routing, service objects, testing, " \
                      "or N+1 queries.".freeze

  def initialize(conversation)
    @conversation = conversation
  end

  def ask(question)
    user_message = @conversation.messages.create!(role: "user", content: question)
    assistant_message = @conversation.messages.create!(role: "assistant", content: answer_for(question))
    [user_message, assistant_message]
  end

  private

  def answer_for(question)
    document = KnowledgeRetrievalService.new.call(question)
    return NOT_FOUND_MESSAGE unless document

    "**#{document.title}**\n\n#{document.content}"
  end
end
