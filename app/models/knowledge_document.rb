class KnowledgeDocument < ApplicationRecord
  validates :title, :content, presence: true
end
