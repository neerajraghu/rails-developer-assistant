class MessagesController < ApplicationController
  def create
    @conversation = Conversation.find(params[:conversation_id])
    content = message_params[:content].to_s.strip

    if content.blank?
      return render turbo_stream: turbo_stream.update("chat-error", "Please enter a question before sending."),
                    status: :unprocessable_entity
    end

    @conversation.update(title: content.truncate(50)) if @conversation.messages.none?
    @user_message, @assistant_message = ChatbotService.new(@conversation).ask(content)
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
