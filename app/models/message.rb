class Message < ApplicationRecord
  enum :role, { user: "user", assistant: "assistant" }

  validates :content, presence: true
  validates :role, presence: true
end
