# Matkovska Quiz Bot — Operations Runbook

Status as of 2026-08-19: **Phase 1 is live and tested.** All three n8n workflows are built,
spec-reviewed, activated, and have passed a full real-Telegram testing pass (see "Before going
live to real students" below). Seeded with generic B1 English→Ukrainian content (copy of the
original bot's), not yet Matkovska's own book — see `CLAUDE.md`'s Phase 1 vs Phase 2 split.

## Components

| Component | Value |
|---|---|
| Telegram bot | `@second_language_quiz_bot`, "Second Language (English) Quiz Bot". Token in local `.env` (`TELEGRAM_MATKOVSKA_BOT_TOKEN`) + Coolify env var, gitignored — never committed. n8n credential: `2h0IXS9CfiMvWZx2` ("Telegram - Matkovska Quiz Bot") |
| n8n main bot workflow | **`O72qRKsNQWGic1xp`** — "Matkovska - Telegram Quiz Bot (Postgres Edition)", 67 nodes, active. Cloned from `7ofHGzHteGrpVaQZ`. Mirror: `scripts/n8n/matkovska-telegram-quiz-bot.json` |
| n8n shared sub-workflow | **`4g8fCNBS0riJC7Z8`** — "Matkovska - Quiz Bot - Send Next Question (shared sub-workflow \| postgres edition)", 11 nodes, active. Cloned from `2B01MahyDGPhuqXr`. Mirror: `scripts/n8n/matkovska-send-next-question.json` |
| n8n dashboard workflow | **`63qwjhYqjXUEOaNP`** — "Matkovska Quiz Bot Dashboard", 19 nodes (2 more than the original plan assumed — an authorization-scope gate: `Scope Allows View` / `Respond: Forbidden API`), active. Cloned from `MK076Yi7J2mknqi8`. Mirror: `scripts/n8n/matkovska-quiz-dashboard.json` |
| New-subscriber notification | Lives as a standalone chain *inside* the main bot workflow (`O72qRKsNQWGic1xp`): `New Subscriber Webhook` → `Check Webhook Secret` → `Notify Oleksandr: New Subscriber` — not a separate workflow |
| Error notification | Reuses the existing shared workflow `❌ Error Notification` (id `XkT4TnNR4NHZRd6f`) via each new workflow's `settings.errorWorkflow` — confirmed set on all three. Delivery mechanism manually test-fired 2026-08-19, confirmed Oleksandr receives the alert |
| Supabase schema | `matkovska_quiz_bot`, same project `cwtidnvbazepqkfweaed` — see `docs/quiz-bot-database.md`. DDL + seed run 2026-08-19: 250 vocab words, 156 grammar questions, all 6 functions + 2 views present |
| Admin dashboard token | `DASHBOARD_ADMIN_TOKEN` in local `.env` + Coolify. Hardcoded as a literal in the dashboard workflow's two `Check Token` Code nodes (matching the original's own design pattern) — never the original bot's `JNppNC8Vbj5s` |
| New-subscriber webhook secret | `MATKOVSKA_NEW_SUBSCRIBER_WEBHOOK_SECRET` in local `.env` + Coolify. Compared in `Check Webhook Secret` against the Supabase Database Webhook's `x-webhook-secret` header — never the original bot's `Gq1W9Nm9qFtiBh1JIAOixJK0pYYhirmL` |
| Dashboard webhook paths | `matkovska-quiz-dashboard` (page) / `matkovska-quiz-dashboard-api` (JSON API) — distinct from the original bot's `quiz-dashboard`/`quiz-dashboard-api` |
| Dashboard admin access | Oleksandr (`863273840`) and Matkovska (`5507304303`) — both in the `ADMIN_CHAT_IDS` gate inside `Reply: Dashboard Link`, and both get `/dashboard` in their per-chat Telegram command scope. Matkovska has not yet started the bot herself, so her chat-scoped command menu isn't set yet (Telegram requires an existing conversation first — same constraint that initially blocked Oleksandr's) |
| Supabase Database Webhook | Configured in Supabase Studio (name: `Matkovska_new_quiz_bot_user`) on `matkovska_quiz_bot.subscribers` INSERT → `matkovska-quiz-bot-new-subscriber`. Confirmed firing correctly end-to-end 2026-08-19 |
| Supabase Exposed schemas | `matkovska_quiz_bot` added under Project Settings → Data API → Exposed schemas — **this step is easy to miss** (see gotcha below) |

**Note on repo visibility**: this repo is **public**. Bot tokens, admin tokens, and webhook shared
secrets live only in the gitignored local `.env`, never in a committed file. The exported workflow
JSON in `scripts/n8n/` has `DASHBOARD_ADMIN_TOKEN`'s real value redacted to a placeholder
(`<DASHBOARD_ADMIN_TOKEN>`) in the two `Check Token` nodes — the live n8n workflow keeps the real
value, only the committed copy is redacted.

## Gotchas carried over from the original bot (verified against its live workflows 2026-08-18)

These are proven, non-hypothetical bug classes from building and operating the original Quiz Bot.
Full detail lives in `moodle-task-builder`'s memory/docs; summarized here so this repo doesn't
silently re-discover them:

- **`Accept-Profile`/`Content-Profile` header is mandatory on every PostgREST call against a
  non-`public` schema** (the Dashboard workflow's style) — omitting it doesn't error, it silently
  targets `public` and 404s. Postgres-credential nodes (the main bot's style) don't need this
  header but DO need every query's schema prefix to actually say `matkovska_quiz_bot` — a
  copy-pasted `quiz_bot.` prefix left in place fails silently in the opposite way: no error, just
  reads/writes the *other* teacher's data, since `service_role` has access to both schemas.
- **n8n's `queryReplacement` "comma-separated values" field splits the whole evaluated string on
  commas** — binding an array directly through it risks the array's own elements being mis-split
  into separate `$1`/`$2`/... parameters. Build arrays as literal SQL text instead, e.g.
  `'ARRAY[' + ids.map(Number).join(',') + ']::bigint[]'` (numeric-only `.map(Number)` keeps this
  safe from injection despite the raw string interpolation).
- **`runOnceForEachItem` Code/HTTP nodes have no error isolation by default** — one bad item (a
  stray test row, a subscriber who blocked the bot, a deleted Telegram account) throws and silently
  kills every other item in the same batch. `onError: "continueErrorOutput"` is applied to `Upsert
  Session (Scheduled)` and `Mark Sent` in this bot's main workflow, matching the original's
  incident fix.
- **`create or replace function` does not replace a function whose argument list changed size** —
  Postgres treats a different arity as a distinct overload. If this schema's functions are ever
  altered to add a parameter, the old-arity overload must be dropped explicitly
  (`drop function if exists ...`) or PostgREST/Postgres may resolve calls to the wrong one.
- **Delete throwaway test rows (`chat_id`s like `-1`, `999001`, `999002`) in the same sitting you
  create them.** A still-`active: true` test subscriber participates fully in real scheduled-send
  logic — this caused a real production incident on the original bot when cleanup was deferred.
- **A GET → patch → PUT round-trip on an n8n workflow can silently drop UI-only default-valued
  fields** (`resource`/`operation` on native nodes, `agent: "toolsAgent"` on AI Agent nodes, etc.) —
  always diff old-vs-new node-by-node after any such edit, don't trust a clean-looking PUT response.
  Confirmed low-impact instances of this during the build: `settings.binaryMode` was dropped on two
  of the three cloned workflows (no binary data used anywhere in this bot, so no practical effect).
- **A webhook whose path contains a dynamic segment (e.g. `:token`) gets registered under a
  UUID-prefixed URL, not the short static-path form.** Not hit this time — none of this bot's
  webhook paths use dynamic segments — but confirm with a live curl before assuming if that ever
  changes.
- **Chart.js `responsive: true` races against async-loaded page content** and can render fully
  blank canvases even with correct underlying data. The dashboard's HTML uses fixed `width`/`height`
  canvas attributes, `responsive: false`, CSS `max-width:100%; height:auto` for graceful scaling.
- **This Supabase account has no MCP/API write tool** — every schema/DDL change is run by hand in
  the SQL editor, and every Supabase Database Webhook is configured by hand via Studio's
  Integrations → Database Webhooks (not the Database → Triggers page, which doesn't offer an
  HTTP-call option until that integration is installed).

## New gotchas discovered building this bot (2026-08-19)

Not present in the original bot's own docs — found while testing this one. Worth checking for if
this "Postgres Edition" template is ever cloned again (e.g. a third teacher's bot):

- **A Postgres node with no `alwaysOutputData` setting outputs *zero* items when its query matches
  zero rows — not one item with null fields.** With zero items, every downstream node in that
  branch simply never executes, silently, no error. This broke `/start` for every first-time
  subscriber (`Get Existing Schedule` found no row → `Build Start Reply` → `Upsert Start` → `Reply:
  Start` never ran — no welcome message, no subscriber row created) and broke `/question` from a
  non-subscriber the same way (`Get Subscriber (On Demand)` → `Is Subscribed?` never ran, so even
  the intended "use /start first" message never sent). **This bug pre-dates this clone** — the
  source template `7ofHGzHteGrpVaQZ` has the identical gap on the identical nodes. It was never
  caught because the actual live englishpusher bot runs on a different ($env+PostgREST/httpRequest)
  architecture, where an empty result still returns one HTTP-response item, not zero. Fix: set
  `alwaysOutputData: true` on any single-entity `WHERE chat_id = $1`-style Postgres lookup node
  whose downstream logic branches on the row being absent. Fixed on `Get Existing Schedule` and
  `Get Subscriber (On Demand)` in this bot's main workflow.
- **A brand-new Telegram bot token can't message *anyone* — including its own admin — until that
  person has personally sent the bot at least one message first.** `sendMessage`/`setMyCommands`
  with a chat-scope both fail with `"Bad Request: chat not found"` until then; this isn't a bug,
  it's how Telegram's Bot API works (a bot can never initiate a first contact). Relevant every time
  a new bot token is issued: the admin has to `/start` their own bot before any notification
  (including the "new subscriber" alert) can reach them, and before chat-scoped command menus can
  be set for them.
- **Adding a new schema to `matkovska_quiz_bot`-style isolation doesn't automatically make it
  reachable via Supabase's REST API** — the schema also has to be added under Project Settings →
  Data API → **Exposed schemas** (a separate, easy-to-miss manual dashboard step, distinct from any
  SQL). Until it is, every PostgREST call with `Accept-Profile`/`Content-Profile` set to that schema
  fails with `406 Not Acceptable`. SQL-editor-based verification (Task 2's row-count/function/view
  checks) never exercises this path at all, since it talks to Postgres directly — the first real
  signal was `/mystats` and the dashboard failing in production. Check this explicitly during setup
  next time rather than assuming it's covered by the DDL step.
- **The Phase 1 `grammar_questions` seed is a point-in-time snapshot, not a live sync — it can
  silently drift from fixes made in the source repos after the copy ran.** `matkovska_quiz_bot.
  grammar_questions` was populated 2026-08-18 via a straight `INSERT ... SELECT ... FROM
  quiz_bot.grammar_questions` (see `docs/quiz-bot-database.md`'s "Phase 1 content seed"). One day
  later, a content-authoring bug was found and fixed upstream: in `englishpusher-grammar-testing`
  (`D:\VIBE CODING\englishpusher-grammar-testing`), 36 of 74 multiple-choice grammar questions
  across 6 topics (`verb-patterns`, `narrative-tenses`, `modifiers`,
  `past-simple-present-perfect`, `apologise-and-give-reasons`, `starting-ending-conversations`)
  had `sentence` and `multipleChoice.question` set to identical text — the import script
  (`grammar_transform.mjs` in the sibling `moodle-task-builder` repo) bakes both into one stored
  `sentence` column as `` `${q.sentence}\n\n${q.multipleChoice.question}` ``, so the bug rendered
  as the same line shown twice in a row in Telegram. The fix landed in `quiz_bot.grammar_questions`
  (commit `c11a2eb` in `englishpusher-grammar-testing`) but **not** in this schema's already-copied
  rows, since there's no ongoing pipeline linking them — confirmed and fixed 2026-08-19 by patching
  the same 36 `source_id`-matched rows via targeted PostgREST `PATCH` calls (not a full re-copy, to
  avoid renumbering `id`s and silently breaking any `answers.question_id` references — there's no
  FK enforcing that link, so a full delete+reinsert would fail silently rather than error). Detect
  this class of bug with: `sentence.split('\n\n')` having exactly 2 parts that are identical after
  trimming. **If `englishpusher-grammar-testing` or `quiz_bot.grammar_questions` changes again in
  the future, this schema needs re-syncing again by hand — nothing does it automatically.**

## Before going live to real students

1. ~~Run every function/view in `docs/quiz-bot-database.md` by hand against a throwaway `chat_id`~~
   — done 2026-08-19: `pick_next_question(999001, '{}')` returned a real word/translation/distractor
   set, no cleanup needed (no row was written).
2. ~~Confirm no node in the cloned workflows references `quiz_bot`, the original bot's Telegram
   token, or its admin dashboard token~~ — done: cross-workflow isolation grep across all three
   workflows, zero matches for all five forbidden strings (`quiz_bot` unprefixed, the original
   Telegram credential id, `TELEGRAM_QUIZ_BOT_TOKEN`, `JNppNC8Vbj5s`, and the original webhook
   secret), independently confirmed twice.
3. ~~Real end-to-end test~~ — done 2026-08-19, all via real Telegram interactions from Oleksandr's
   own chat, cross-checked against actual executions: `/start`, forced scheduled send, both
   correct/wrong feedback paths, `/question` on-demand, `/settings` (cadence/day/content all
   confirmed persisting), a full 3-question round (session row confirmed cleaned up on completion),
   `/dashboard` (admin view), `/mystats` (personal view).
4. ~~Confirm the shared error-notification workflow actually fires~~ — done 2026-08-19: manually
   executed `❌ Error Notification` directly, confirmed Oleksandr receives the Telegram alert.
5. Grant Matkovska dashboard admin access — her chat_id is already in the gate/allowlist, but she
   still needs to `/start` the bot herself before: (a) she can receive any message from it at all,
   and (b) her chat-scoped `/dashboard` command menu entry can be set (see the new gotcha above).
   **Not yet done as of 2026-08-19** — next real step before wider rollout, per `CLAUDE.md` rule 5
   (teacher reviews before wide student sign-up).
