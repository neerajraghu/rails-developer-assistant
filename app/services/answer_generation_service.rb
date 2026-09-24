require "net/http"

class AnswerGenerationService
  ENDPOINT = "https://openrouter.ai/api/v1/chat/completions".freeze
  DEFAULT_MODEL = "cohere/north-mini-code:free".freeze

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a helpful Rails developer assistant. Answer the user's question using
    only the context below. Keep the answer clear, concise, and beginner-friendly.
    If the context does not fully answer the question, say what you can from it
    rather than making something up.
  PROMPT

  Error = Class.new(StandardError)

  def call(question:, document:)
    response = post_chat_completion(question, document)
    response.dig("choices", 0, "message", "content")&.strip
  rescue StandardError => e
    Rails.logger.error("AnswerGenerationService failed: #{e.class} #{e.message}")
    nil
  end

  private

  def post_chat_completion(question, document)
    uri = URI(ENDPOINT)
    request = Net::HTTP::Post.new(
      uri,
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}",
      "HTTP-Referer" => "https://github.com/rails-developer-assistant",
      "X-Title" => "Rails Developer Assistant"
    )
    request.body = {
      model: model,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: "Context:\n#{document.title}\n#{document.content}\n\nQuestion: #{question}" }
      ]
    }.to_json

    http_response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    unless http_response.is_a?(Net::HTTPSuccess)
      raise Error, "OpenRouter returned #{http_response.code}: #{http_response.body}"
    end

    JSON.parse(http_response.body)
  end

  def api_key
    ENV.fetch("OPENROUTER_API_KEY") { raise Error, "OPENROUTER_API_KEY is not set" }
  end

  def model
    ENV.fetch("OPENROUTER_MODEL", DEFAULT_MODEL)
  end
end
