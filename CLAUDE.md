# Second Language Quiz Bot — Claude Code Instructions
# Target: Telegram vocabulary/grammar quiz bot for Matkovska's "English Language as a Second Language" course

## What this project does

A Telegram bot that sends each subscribed student one B1-level English quiz question (vocabulary
or grammar) per day/week, personalized from their own answer history, plus a teacher dashboard so
Matkovska can see her students' results without asking anyone to query a database for her.

Runs on Oleksandr's own infrastructure — n8n (Hetzner, shared with the original Quiz Bot) and
Supabase (same project, isolated schema `matkovska_quiz_bot`) — not a separate hosting setup for
this teacher. At this scale (100–300 students, text-only quiz records), Supabase storage is a
non-issue; the real scaling lever is n8n compute on the shared Hetzner box, already budgeted for
two bots' subscriber pools spreading their scheduled sends across 24 hours rather than one fixed
hour.

---

## Relationship to the original Quiz Bot

This is the second deployment of a proven pattern. The first Quiz Bot (englishpusher, B1
English→Ukrainian vocab) lives in a sibling repo, `moodle-task-builder`
(`docs/quiz-bot-database.md`, `docs/telegram-bot-runbook.md`'s "Quiz Bot" section, and
`docs/superpowers/specs/2026-08-06-telegram-quiz-bot-design.md` onward), live since 2026-08-06 and
since grown to include grammar questions, 3-question trivia-style rounds, and a teacher dashboard.

**This repo does not depend on that one at runtime** — fully separate Supabase schema, fully
separate n8n workflows, fully separate Telegram bot token. But when something here looks
underspecified, that repo's docs are the reference implementation and have almost certainly
already solved the same problem, including the hard-won operational lessons — read them before
re-deriving a solution from scratch. See `docs/telegram-bot-runbook.md` here for the specific
gotchas worth carrying over.

## Phase 1 vs Phase 2

- **Phase 1 (current work)** — full feature clone of the original bot: subscribe, daily/weekly
  cadence, vocab + grammar questions, 3-question trivia rounds, teacher dashboard, `/mystats`.
  Seeded with a **copy of the original bot's B1 English→Ukrainian content** (250 words / 9 topics +
  grammar questions) so the bot is fully live and usable immediately, ahead of Matkovska's own
  book being ready. See `docs/superpowers/specs/2026-08-18-matkovska-quiz-bot-design.md`.
- **Phase 2 (future, not started)** — once Matkovska shares her book (PDF or JPEG scans), build a
  Claude Skill in this repo that reads it and produces rows matching `vocab_words` /
  `grammar_questions` below, replacing the seed content. **Deliberately not designed yet** — the
  book's actual format/structure isn't known, so brainstorm this fresh once it's in hand rather
  than guessing ahead of time. Do not start this until the book actually exists.

---

## Project structure

```
second-language-quiz-bot/
├── CLAUDE.md                          ← you are here
├── docs/
│   ├── quiz-bot-database.md           ← Supabase schema contract (matkovska_quiz_bot) — read this
│   │                                      in full before touching the database
│   ├── telegram-bot-runbook.md        ← ops: workflow IDs, secrets, restart/testing procedures,
│   │                                      gotchas carried over from the original bot
│   └── superpowers/
│       ├── specs/                     ← design docs (brainstorming skill output)
│       └── plans/                     ← implementation plans (writing-plans skill output)
├── scripts/
│   └── n8n/                           ← exported workflow JSON, once built. Repo mirrors live
│                                          n8n state, never the reverse — always GET before editing.
└── skills/                            ← Phase 2's book-processing Claude Skill goes here, once built
```

---

## Core rules (never break)

1. **Schema from `docs/quiz-bot-database.md` only** — no invented fields, no guesses. If Phase 2's
   book-processing skill needs a field that doesn't exist yet, that's a schema migration to design
   deliberately, not a field to add ad hoc.
2. **No RLS on `matkovska_quiz_bot`** — isolation is via `GRANT`s to `service_role` only. Every
   PostgREST-style Supabase call needs an explicit `Accept-Profile`/`Content-Profile:
   matkovska_quiz_bot` header; Postgres-credential-style n8n nodes rely on schema-qualified table
   names instead. Both are explained in the database contract.
3. **`service_role` has access to every schema in this Supabase project**, including the original
   bot's `quiz_bot`. Isolation is enforced by what each query/header actually says, not by
   credentials — after cloning any n8n workflow from the original bot, explicitly verify (grep the
   exported JSON) that no node was left pointing at `quiz_bot` instead of `matkovska_quiz_bot`.
4. **Never reuse secrets from the original bot.** Fresh Telegram bot token, fresh admin dashboard
   token, fresh webhook shared secret. `subscribers.dashboard_token` is generated per-row by the
   database itself (column default), never hand-set.
5. **Teacher reviews before wide student sign-up.** Matkovska gets dashboard access as admin (once
   her Telegram chat_id is known) so she can see results — but Phase 1 ships with generic seed
   content, not her book, so treat the initial rollout as a working demo for her to confirm, not an
   assumed-final product.
6. **This repo mirrors live n8n/Supabase state, never the reverse.** GET a workflow before editing
   it, diff old-vs-new after any API round-trip (n8n has repeatedly, silently dropped UI-only
   default fields on GET — see the runbook), and re-sync the repo's JSON file after any live edit.
7. **Dry-run / review before anything goes live to real students** — same ethos as the H5P side of
   this family of projects: generate, show what will happen, only then act.

---

## Infrastructure (shared instances, separate namespace)

- **Supabase**: same project as `app-englishpusher` / the original Quiz Bot
  (`cwtidnvbazepqkfweaed`), new schema `matkovska_quiz_bot`. Full DDL in
  `docs/quiz-bot-database.md`. No Supabase MCP/API tool exists for this account — all SQL is run by
  hand in the Supabase SQL editor.
- **n8n**: same Hetzner instance (`https://n8n.englishpusher.in.ua`) as the original bot, via the
  `claude.ai englishpusher n8n` MCP connector. New, separate workflows, cloned from the original
  bot's (some from its `$env`+PostgREST workflows, some from its Postgres-credential "Postgres
  Edition" workflows) — see the design spec for exactly which, and the runbook for live IDs once
  built.
- **Telegram bot**: new bot via BotFather, separate token, separate webhook — not created yet as of
  this repo's initial setup.
