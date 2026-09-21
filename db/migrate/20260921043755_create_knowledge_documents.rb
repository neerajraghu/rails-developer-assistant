class CreateKnowledgeDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :knowledge_documents do |t|
      t.string :title
      t.text :content
      t.string :category
      t.string :source

      t.timestamps
    end

    # A GIN index on an expression (rather than a stored tsvector column) so search
    # stays in sync with title/content automatically, no trigger or callback needed
    # to keep an extra column up to date. Raw SQL isn't auto-reversible, so this
    # wraps it in `reversible` rather than leaving `db:rollback` broken.
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE INDEX index_knowledge_documents_on_search_vector
          ON knowledge_documents
          USING GIN (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, '')));
        SQL
      end

      dir.down do
        execute "DROP INDEX index_knowledge_documents_on_search_vector;"
      end
    end
  end
end
