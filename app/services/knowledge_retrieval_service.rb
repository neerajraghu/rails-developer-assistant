# Finds the best matching document using Postgres full-text search.
class KnowledgeRetrievalService
  TSVECTOR_EXPRESSION = "to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))".freeze

  def call(question)
    # Match if any word matches, not all of them.
    tsquery = "to_tsquery(replace(plainto_tsquery('english', #{quoted(question)})::text, ' & ', ' | '))"

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
