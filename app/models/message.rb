class Message < ApplicationRecord
  belongs_to :conversation

  enum :role, { user: "user", assistant: "assistant" }

  validates :content, presence: true
  validates :role, presence: true
end
