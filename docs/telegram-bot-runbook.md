# Matkovska Quiz Bot — Operations Runbook

Status as of 2026-08-18: **not yet built.** This file is scaffolding — sections below get filled in
as Phase 1 is actually implemented (see `docs/superpowers/plans/` once the implementation plan
exists). Written now so the operational knowledge lands in one place from day one instead of being
reconstructed after the fact.

## Components (fill in once built)

| Component | Value |
|---|---|
| Telegram bot | not yet created via BotFather |
| n8n main bot workflow | not yet cloned — base: `Englishpusher - Telegram Quiz Bot (Postgres Edition)`, id `7ofHGzHteGrpVaQZ`, on the Hetzner instance |
| n8n shared sub-workflow | not yet cloned — base: `Englishpusher - Quiz Bot - Send Next Question (shared sub-workflow \| postgres edition)`, id `2B01MahyDGPhuqXr` |
| n8n dashboard workflow | not yet cloned — base: `Quiz Bot Dashboard`, id `MK076Yi7J2mknqi8` (kept in its existing `$env`+PostgREST form — no Postgres-credential version exists for this one) |
| New-subscriber notification | not yet located/ported — likely lives inside the original bot's live main workflow (`kWFvCbLnvWSdLtFq`) rather than as its own workflow; confirm exact source before porting |
| Error notification | reuse the existing shared workflow `❌ Error Notification` (id `XkT4TnNR4NHZRd6f`) via each new workflow's `settings.errorWorkflow` — no new clone needed, this one's already account-wide |
| Supabase schema | `matkovska_quiz_bot`, same project `cwtidnvbazepqkfweaed` — see `docs/quiz-bot-database.md` |
| Admin dashboard token | not yet generated — must be a fresh random value, never the original bot's `JNppNC8Vbj5s` |
| Dashboard webhook paths | not yet chosen — must be NEW paths, distinct from the original bot's `quiz-dashboard`/`quiz-dashboard-api` (n8n webhook paths are unique per instance; the original bot's are already claimed on this same Hetzner instance) |
| Matkovska's Telegram chat_id | not yet known — needed to grant her dashboard admin access |

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
  kills every other item in the same batch. The original bot's scheduled-send path needed
  `onError: "continueErrorOutput"` added to both its send node and its "mark sent" node after a
  real incident (a leftover test `chat_id -1` row blocked an entire hour's real sends). **The
  Postgres Edition base workflow this repo clones from predates that fix — it must be re-applied
  here, not assumed present.**
- **`create or replace function` does not replace a function whose argument list changed size** —
  Postgres treats a different arity as a distinct overload. If this schema's functions are ever
  altered to add a parameter, the old-arity overload must be dropped explicitly
  (`drop function if exists ...`) or PostgREST/Postgres may resolve calls to the wrong one.
- **Delete throwaway test rows (`chat_id`s like `-1`, `999001`) in the same sitting you create
  them.** A still-`active: true` test subscriber participates fully in real scheduled-send logic —
  this caused a real production incident on the original bot when cleanup was deferred.
- **A GET → patch → PUT round-trip on an n8n workflow can silently drop UI-only default-valued
  fields** (`resource`/`operation` on native nodes, `agent: "toolsAgent"` on AI Agent nodes, etc.) —
  always diff old-vs-new node-by-node after any such edit, don't trust a clean-looking PUT response.
- **A webhook whose path contains a dynamic segment (e.g. `:token`) gets registered under a
  UUID-prefixed URL, not the short static-path form.** If a "prettier URL" is ever wanted for this
  bot's dashboard, confirm the actual registered path with a live curl before assuming — a
  dynamic-segment path made the original bot's dashboard URL longer, not shorter, the opposite of
  the goal.
- **Chart.js `responsive: true` races against async-loaded page content** and can render fully
  blank canvases even with correct underlying data. The original dashboard's fix: fixed
  `width`/`height` canvas attributes, `responsive: false`, CSS `max-width:100%; height:auto` for
  graceful scaling instead. Apply the same pattern here rather than rediscovering the race.
- **This Supabase account has no MCP/API write tool** — every schema/DDL change is run by hand in
  the SQL editor, and every Supabase Database Webhook (e.g. for new-subscriber notifications) is
  configured by hand via Studio's Integrations → Database Webhooks (not the Database → Triggers
  page, which doesn't offer an HTTP-call option until that integration is installed).

## Before going live to real students

1. Run every function/view in `docs/quiz-bot-database.md` by hand against a throwaway `chat_id`,
   spot-check results, then delete the throwaway row immediately (see gotcha above).
2. Confirm no node in the cloned workflows references `quiz_bot` (the original schema), the
   original bot's Telegram token, or its admin dashboard token — grep the exported JSON for all
   three before activating anything.
3. Real end-to-end test: `/start`, a forced scheduled send (temporarily set a test subscriber's
   `send_hour` to the current hour), both correct/wrong feedback paths, `/question` on-demand,
   `/settings`, a full 3-question trivia round, dashboard load (admin view), `/mystats` (personal
   view) — cross-checked directly against Supabase, not assumed from the workflow's own success
   status.
4. Confirm the shared error-notification workflow actually fires for a deliberately-broken node in
   this bot's workflows (not just assumed wired because `settings.errorWorkflow` is set).
5. Grant Matkovska dashboard admin access once her chat_id is known, and confirm she can load it.
