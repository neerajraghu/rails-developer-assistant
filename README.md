# Rails Developer Assistant

Small chatbot that answers Rails questions from a curated knowledge base
(`db/knowledge/*.md`). Postgres full-text search finds the closest doc, then
an LLM (OpenRouter) writes the actual answer from it.

## Setup

```
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Visit http://localhost:3000

## Env vars

Copy `.env.example` to `.env` and fill in:

- `OPENROUTER_API_KEY` - free key from openrouter.ai. Without it the app still
  works, it just shows the raw doc instead of a generated answer.
- `OPENROUTER_MODEL` - optional, defaults to a free model.

## Deploy (Render)

- Web service + Postgres db
- Env vars: `RAILS_MASTER_KEY`, `DATABASE_URL`, `OPENROUTER_API_KEY`
- Release command: `bin/rails db:migrate`
- Seed once after first deploy: `bin/rails db:seed`
