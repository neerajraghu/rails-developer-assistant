class MessagesController < ApplicationController
  def index
    @messages = Message.order(:created_at)
  end

  def create
    content = message_params[:content].to_s.strip

    if content.blank?
      return render turbo_stream: turbo_stream.update("chat-error", "Please enter a question before sending."),
                    status: :unprocessable_entity
    end

    @user_message, @assistant_message = ChatbotService.new.ask(content)
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
