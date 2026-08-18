# Matkovska Quiz Bot — Phase 1 Design (Infrastructure Clone)

## Purpose

Oleksandr's friend Matkovska teaches "English Language as a Second Language" and wants the same
Telegram quiz-bot experience already built and running for the original englishpusher course
(`moodle-task-builder`'s Quiz Bot, live since 2026-08-06). She'll eventually provide her own course
book (PDF or JPEG scans) as the real content source.

This spec covers **Phase 1 only**: standing up a fully working twin bot — same feature set, own
Supabase schema, own n8n workflows, own Telegram bot, own GitHub repo — seeded with a copy of the
original bot's B1 English→Ukrainian content so it's live and testable immediately. **Phase 2** (a
Claude Skill that reads Matkovska's actual book and replaces the seed content) is explicitly out of
scope here — it gets its own brainstorm once the book exists in a known format. Designing it now,
against material nobody has seen yet, would mean guessing at input shape and content type
(vocabulary vs. grammar vs. both) that only the real book can answer.

## Why a separate Supabase project isn't needed

Raised and settled during brainstorming: 100–300 students generating text-only quiz-answer rows is
trivial data volume — a few MB/year even at high usage, nowhere near Supabase's free-tier 500MB
cap. No Supabase Auth is involved (identity is the Telegram `chat_id`, accessed only via
`service_role`), so there's no per-project MAU billing metric either. The one real scaling
consideration is **n8n compute on the shared Hetzner box**, now running two bots' scheduled sends —
already partly designed for (each subscriber defaults to their own signup hour, not a fixed 9am, so
growth spreads across the day rather than piling onto one hour).

## Decisions locked in during brainstorming

- **Feature scope**: full clone of the original bot's current feature set — subscribe,
  daily/weekly cadence, vocab + grammar questions, 3-question trivia-style rounds, teacher/admin
  dashboard, `/mystats` personal dashboard. Not an MVP-then-grow path like the original bot took;
  ship it complete from day one.
- **Course shape**: same as the original (English learning, B1-ish level, Ukrainian-speaking
  students) — just different source content. The schema's `level` column isn't actually
  constrained to `'B1'` by a check constraint (just defaulted), so this required no schema changes,
  only different row content.
- **Interim content (Phase 1)**: a straight copy of the original bot's `vocab_words` and
  `grammar_questions` rows (same Supabase project, same-database cross-schema `INSERT ... SELECT`
  — no re-running the original curation import). This makes the bot fully live and usable with real
  quiz mechanics from day one, not just structurally tested. Replaced wholesale in Phase 2.
- **Repo scope**: standalone repo (`tauruskin/second-language-quiz-bot`), not a shared
  multi-teacher platform. Mirrors how `moodle-task-builder` itself is scoped to one teacher. No
  migration of the original bot's docs/scripts out of `moodle-task-builder` — that repo is
  unaffected by this one.
- **Naming**: Supabase schema `matkovska_quiz_bot`; GitHub repo `second-language-quiz-bot`
  (already created by Oleksandr, cloned locally to `D:\VIBE CODING\second-language-quiz-bot`,
  matching the sibling-folder convention already used for `app-englishpusher` and
  `englishpusher-grammar-testing`).
- **Where this project's docs/plans/skill live**: entirely in this new repo, not in
  `moodle-task-builder`. Oleksandr will run Claude Code from this repo directly for all further
  work here, including Phase 2's book-processing skill — kept deliberately separate so the two
  projects don't get confused with each other.

## n8n workflow strategy (the one real technical fork)

Oleksandr's instinct going in was to reuse the original bot's **"Postgres Edition"** workflows —
correct, and confirmed the right call by inspecting their actual live state on the Hetzner instance
during this session (not assumed from memory). Two things came out of that inspection worth
recording:

**What "Postgres Edition" actually covers, verified live:**
`Englishpusher - Telegram Quiz Bot (Postgres Edition)` (id `7ofHGzHteGrpVaQZ`) and its shared
sub-workflow `Englishpusher - Quiz Bot - Send Next Question (... | postgres edition)` (id
`2B01MahyDGPhuqXr`) were built 2026-08-14 specifically for resale portability — they replace every
`$env`+PostgREST Supabase call with a native n8n Postgres credential, so cloning them mostly means
find-and-replace of the `quiz_bot.` schema prefix to `matkovska_quiz_bot.` across each node's SQL
text, rather than juggling `Accept-Profile`/`Content-Profile` headers on ~20 separate HTTP nodes.
They already include grammar questions and 3-question trivia sessions (both shipped before
2026-08-14). **They do NOT include three things added to the live bot afterward**, confirmed by
their `updatedAt` timestamps being frozen at creation:
1. `/dashboard` and `/mystats` command routing (added 2026-08-17) — `Route Action` here has 12
   rules, the live bot's has 14.
2. The per-item `onError: "continueErrorOutput"` error-isolation fix on the scheduled-send path
   (added 2026-08-15, after a real incident where one bad subscriber row silently killed an entire
   hour's sends for everyone). Neither `Get Due Subscribers` nor `Mark Sent`-equivalent nodes here
   have it.
3. A workflow-level `settings.errorWorkflow` — the live bot and the Dashboard workflow both point
   at the shared `❌ Error Notification` workflow (id `XkT4TnNR4NHZRd6f`); this one has no
   `errorWorkflow` set at all, so as-is, a crash here notifies no one.

**Decision: use Postgres Edition as the base, and explicitly port all three gaps above during the
build** — not just clone-and-ship. All three are small, mechanical, and already have a proven fix
to copy from the live bot; skipping them would re-introduce a bug class that has already caused one
real production incident.

**Dashboard**: no Postgres-credential version exists for `Quiz Bot Dashboard` (id
`MK076Yi7J2mknqi8`) — clone it in its current `$env`+PostgREST form rather than doing a fresh,
unproven Postgres-credential conversion. This is the cheaper choice specifically *because* the
one-time Coolify groundwork (`N8N_BLOCK_ENV_ACCESS_IN_NODE=false`, `SUPABASE_URL`/
`SUPABASE_SERVICE_ROLE_KEY` already set) is already paid for by the original bot's setup — the new
bot only needs one new env var (its own Telegram token) added via Coolify's Environment Variables
panel, no compose-file editing required this time. Needs: new webhook paths (the original's
`quiz-dashboard`/`quiz-dashboard-api` are already claimed on this same n8n instance), a fresh admin
token (never reuse `JNppNC8Vbj5s`), and the frontend's hardcoded `/webhook/quiz-dashboard-api`
string in the returned HTML updated to match.

**New-subscriber notification**: not found as its own workflow during this session's search — it
most likely lives as a Webhook Trigger + a few nodes added directly into the live bot's main
workflow (`kWFvCbLnvWSdLtFq`), which is too large to safely fetch in full without risking the same
91KB response-cap issue documented for that workflow elsewhere. **Locating its exact source and
porting it is left to the implementation plan**, not guessed here.

**Error notification**: no new workflow needed — reuse the existing account-wide `❌ Error
Notification` workflow via `settings.errorWorkflow` on every new workflow, matching how the
original bot's Dashboard workflow already does it.

**Isolation risk worth stating plainly**: `service_role` has access to every schema in this
Supabase project, including the original bot's `quiz_bot`. Nothing at the credential level stops a
copy-pasted node from silently reading or writing the wrong teacher's data — the only thing that
does is every node's query/header actually saying `matkovska_quiz_bot`. This is the one real cost
of "clone by copy-paste" over a from-scratch build, and it's fully addressable mechanically: after
cloning, grep the exported JSON for the old schema name, the old bot token, and the old admin token
— zero matches required before activating anything. Captured as a non-optional step in the runbook.

**Who executes the n8n cloning**: Oleksandr, directly via the n8n MCP tools — same pattern already
used for the original bot's Hetzner migration. This spec and the implementation plan describe
*what* to clone and *what to change*; the actual node-by-node edits happen in an n8n session, not
by editing exported JSON files by hand.

## Supabase

Full DDL in `docs/quiz-bot-database.md` — the consolidated terminal schema (not a migration
history, since this is a fresh deploy), including the dashboard's backing views/functions and the
`dashboard_token` column. **Both of those were found missing from the original repo's own
`quiz-bot-database.md` while preparing this one** — recovered from that repo's separate dashboard
design spec and from memory of the actual column, respectively. Worth fixing in the original repo
too at some point; not done as part of this work.

Run by Oleksandr in the Supabase SQL editor (no MCP/API write tool exists for this account): the
schema DDL, then the Exposed-schemas dashboard step, then the content-seed `INSERT ... SELECT`.

## Teacher dashboard access

Same two-part pattern as the original bot, not a choice between alternatives:

1. **The dashboard webhook itself** is gated by one shared admin token (a literal string compared
   in the `Check Token` nodes) — both Oleksandr and Matkovska use links containing this same token.
   No chat_id involved at this layer.
2. **The bot's `/dashboard` command** is registered per-chat via Telegram's `setMyCommands` scope,
   so it only appears in the Telegram menus of people who should have it — today that's just
   Oleksandr; for this bot it should be Oleksandr *and* Matkovska. That's what needs her chat_id:
   to register her chat as a second per-chat scope for the command, plus the matching
   defense-in-depth chat_id check inside `Route Action`'s JS (mirroring the original bot's).

Once Oleksandr creates the new Telegram bot and gets Matkovska's chat_id (either she messages the
bot and he reads it from Supabase, or he asks her directly), both steps above get her chat_id
added. Not blocking the rest of Phase 1 — everything else can be built and tested before her
chat_id is known.

## Non-goals for this spec

- Phase 2 (book-processing Claude Skill) — deliberately undesigned until the book exists.
- Any change to the original bot's live workflows, schema, or docs (aside from the two documentation
  gaps noted above, which are flagged, not fixed, here).
- A shared/parameterized n8n workflow serving both teachers from one definition — explicitly
  rejected in favor of duplication, per Oleksandr's own stated preference and because the
  isolation-by-duplication model is already proven for the original bot's own multi-workflow setup.

## Testing and rollout

See `docs/telegram-bot-runbook.md`'s "Before going live to real students" checklist — mirrors the
original bot's own launch discipline (real `/start`, forced scheduled send, both feedback paths,
dashboard load, immediate cleanup of any throwaway test `chat_id`).
