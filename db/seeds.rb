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
