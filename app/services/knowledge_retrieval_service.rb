# Finds the KnowledgeDocument that best matches a question, using Postgres'
# native full-text search (tsvector/tsquery) rather than a vector/embeddings
# search. Good enough for a small, curated knowledge base like this one.
#
# `@@` only filters to rows that match at all, it doesn't rank them, so the
# score is also selected and ordered on explicitly via ts_rank, otherwise
# `.first` would return an arbitrary matching row rather than the best one.
class KnowledgeRetrievalService
  TSVECTOR_EXPRESSION = "to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))".freeze

  def call(question)
    tsquery = "plainto_tsquery('english', #{quoted(question)})"

    KnowledgeDocument
      .select("knowledge_documents.*, ts_rank(#{TSVECTOR_EXPRESSION}, #{tsquery}) AS relevance")
      .where("#{TSVECTOR_EXPRESSION} @@ #{tsquery}")
      .order(Arel.sql("relevance DESC"))
      .first
  end

  private

  def quoted(question)
    ActiveRecord::Base.connection.quote(question)
  end
end
