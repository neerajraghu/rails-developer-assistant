# Loads every db/knowledge/*.md file into a KnowledgeDocument.
#
# Each file has a small YAML frontmatter (title, category) followed by the
# document body. Re-running this (e.g. `rails db:seed`) upserts by `source`,
# so editing a .md file and reseeding updates its existing row instead of
# duplicating it.

require "yaml"

Dir.glob(Rails.root.join("db/knowledge/*.md")).sort.each do |path|
  raw = File.read(path)
  _, frontmatter, body = raw.split(/^---\s*$/, 3)
  metadata = YAML.safe_load(frontmatter)
  source = path.sub("#{Rails.root}/", "")

  doc = KnowledgeDocument.find_or_initialize_by(source: source)
  doc.update!(
    title: metadata.fetch("title"),
    category: metadata.fetch("category"),
    content: body.strip
  )

  puts "Seeded: #{doc.title}"
end

puts "#{KnowledgeDocument.count} knowledge documents in the database."
