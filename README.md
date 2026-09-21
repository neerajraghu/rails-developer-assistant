# Rails Developer Assistant

## Overview

A small chatbot that answers questions about Ruby on Rails development, using a
curated knowledge base instead of general knowledge. Ask it about `has_many`,
migrations, N+1 queries, service objects, and it answers from documents written
specifically for this project. Ask it something outside that knowledge base, and it
says so, it never pretends to know something it doesn't have a source for.

Built as a learning project to demonstrate a search/retrieval-based chatbot inside a
Ruby on Rails application.

## Features

- Ask a Rails question in plain English and get an answer sourced from a knowledge base
- Conversation history is stored and persists across page refreshes
- Start multiple separate conversations
- Clear message when no matching knowledge is found, instead of guessing
- Clear message when you submit an empty question

## Architecture

```
Browser (Turbo)
      |
      v
ConversationsController / MessagesController   (thin, no business logic)
      |
      v
ChatbotService                                 (orchestrator)
      |
      +--> KnowledgeRetrievalService --> KnowledgeDocument (Postgres, full-text search)
      |
      v
Message (persisted: user + assistant turns)
      |
      v
Turbo Stream --> appends the new messages to the page, no full reload
```

- **Controllers** only load records and call one service.
- **`ChatbotService`** is the single place that knows the whole flow: store the
  question, ask retrieval for an answer, store the reply.
- **`KnowledgeRetrievalService`** only knows how to search, nothing about
  conversations or chatbots.

## How the search approach works

This project does **not** call an LLM. It's a **search/retrieval-based** chatbot, one
of several valid approaches for this kind of assignment (the others being
recommendation, full RAG, or similarity/embeddings search).

```
User question
      |
      v
KnowledgeRetrievalService searches KnowledgeDocument
  using Postgres' built-in full-text search (tsvector / tsquery, ranked by ts_rank)
      |
      v
Best-matching document found?
   yes -> its title + content is the answer
   no  -> a clear "not in my knowledge base" message
      |
      v
Both the question and the answer are stored as Messages
      |
      v
Turbo Stream displays them
```

A quick note on terms, since this project deliberately uses only the first of these:

- **Search / retrieval**: find the most relevant document(s) for a question. That's
  the whole answer here, no rewriting, no summarizing.
- **RAG (Retrieval-Augmented Generation)**: retrieval *plus* an LLM that generates a
  fresh answer using the retrieved text as context. Needs an API key and an external
  call.
- **Embeddings / vector search**: a smarter version of the retrieval step, matching by
  *meaning* (via numeric vectors) instead of by keyword. Would improve on Postgres
  full-text search but adds real complexity (see Future Improvements).

## Tech Stack

- Ruby on Rails 8
- PostgreSQL (with a GIN index over a `tsvector` expression for search, no extra
  search gem needed)
- Hotwire (Turbo) for the chat UI, no separate frontend framework
- Puma web server

## Setup

```bash
git clone <your-repo-url>
cd rails-developer-assistant
bundle install
bin/rails db:create db:migrate
bin/rails db:seed        # loads db/knowledge/*.md into the database
bin/rails server
```

Visit `http://localhost:3000`.

### Environment Variables

None required to run this locally, there's no external API key. `config/database.yml`
defaults to local Postgres credentials (`postgres` / `postgres` on `localhost:5432`),
overridable via `POSTGRES_HOST`/`POSTGRES_PORT`/`POSTGRES_USER`/`POSTGRES_PASSWORD` if
your local setup differs. For production, see Deployment below.

## Example Questions

- What is `has_many` in Rails?
- What is the difference between `has_many` and `has_one`?
- How do Rails migrations work?
- What is an N+1 query?
- How do I create a Rails service object?
- What is the difference between `find` and `find_by`?
- How does Rails routing work?
- How should I write a Rails model validation?
- How do I write a request spec?

## Architecture Decisions

- **PostgreSQL**: matches Render's managed database offering exactly (no external
  database host needed), and its full-text search (`tsvector`/`tsquery`/`ts_rank`) is
  built in, no extra search gem or service needed.
- **Search instead of an LLM/RAG**: this satisfies the assignment's requirement for "a
  suitable recommendation, search, RAG, or similarity-based approach" without needing
  an API key, external cost, or network dependency, keeping the whole thing runnable
  offline with zero secrets.
- **Knowledge as markdown files, not hand-typed records**: `db/knowledge/*.md` files
  with a small YAML frontmatter, loaded by `db/seeds.rb`. Adding a new topic means
  adding a file and reseeding, not writing `KnowledgeDocument.create!` by hand.
- **No background jobs, no Solid Queue/Cache/Cable databases**: this app has no jobs
  and no ActionCable broadcasts, so it skips Rails 8's default multi-database split
  for those and just uses one Postgres database, one less thing to configure on
  deploy.

## Limitations

- Answers are whole documents, not synthesized or summarized text, if a document is
  long, the whole thing is shown.
- Retrieval is keyword-based (Postgres full-text search). A question phrased very
  differently from the document's own wording may not match, even if the concept is
  the same.
- No authentication, anyone with the URL can see and add conversations.
- No follow-up context: each question is answered independently of prior turns in the
  same conversation.

## Future Improvements

- Embeddings/vector search (e.g. via the `pgvector` Postgres extension) for matching
  by meaning instead of keyword overlap.
- An actual LLM call (RAG) to synthesize a natural-language answer from the retrieved
  document instead of returning it verbatim.
- Better document chunking (split long docs into smaller, more precisely retrievable
  sections).
- Streaming responses.
- A feedback mechanism ("was this helpful?").
- Source citations shown alongside the answer.

## Learning Outcomes

Building this project covered:

- The difference between plain search/retrieval, full RAG, and embeddings-based search
- How to keep a Rails app's business logic in service objects instead of controllers
- Postgres full-text search: `tsvector`, `tsquery`, `ts_rank`, and the gotcha that a
  `WHERE ... @@ ...` match needs an explicit `ORDER BY` on the rank, or results come
  back in an arbitrary order, not the best match first
- Building a real-time-feeling UI with Hotwire/Turbo Streams, no JavaScript framework
- Loading structured content (markdown + YAML frontmatter) into the database through a
  seed task instead of hand-written records
- Matching an app's infrastructure to its actual deployment target, switching from
  MySQL to Postgres once it was clear Render's managed database is Postgres-only

## Deployment (Render)

1. Push this repository to GitHub.
2. In the [Render dashboard](https://dashboard.render.com/), create a new **PostgreSQL**
   database. Render gives you an internal connection string once it's created.
3. Create a new **Web Service**, connect it to this GitHub repository.
4. Set environment variables in the Web Service's dashboard:
   - `RAILS_MASTER_KEY`, the contents of your local `config/master.key` file (never
     commit that file, it's already gitignored).
   - `DATABASE_URL`, the internal connection string from step 2 (Render can wire this
     automatically if you add the database from the Web Service's Environment tab
     instead of creating it separately).
5. Render runs the build command (`bundle install`, asset precompilation) automatically
   from the detected Rails app.
6. Set the release command to `bin/rails db:migrate` so migrations run automatically on
   every deploy.
7. Render starts the app with `bin/rails server -p $PORT -e production`, Render assigns
   the port through that `PORT` environment variable, don't hardcode a port.
8. Seed the knowledge base once, either add `bin/rails db:seed` to the release command,
   or run it manually from Render's shell after the first deploy.
