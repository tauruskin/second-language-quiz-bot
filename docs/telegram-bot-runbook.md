# Matkovska Quiz Bot — Operations Runbook

Status as of 2026-08-18: **not yet built.** This file is scaffolding — sections below get filled in
as Phase 1 is actually implemented (see `docs/superpowers/plans/` once the implementation plan
exists). Written now so the operational knowledge lands in one place from day one instead of being
reconstructed after the fact.

## Components (fill in once built)

| Component | Value |
|---|---|
| Telegram bot | **created and verified** (`getMe` confirmed) — `@second_language_quiz_bot`, "Second Language (English) Quiz Bot". Token in local `.env` (`TELEGRAM_MATKOVSKA_BOT_TOKEN`), gitignored — never committed. Still needs: Coolify env var + a new n8n Telegram credential (see "Secrets handoff" below) |
| n8n main bot workflow | not yet cloned — base: `Englishpusher - Telegram Quiz Bot (Postgres Edition)`, id `7ofHGzHteGrpVaQZ`, on the Hetzner instance |
| n8n shared sub-workflow | not yet cloned — base: `Englishpusher - Quiz Bot - Send Next Question (shared sub-workflow \| postgres edition)`, id `2B01MahyDGPhuqXr` |
| n8n dashboard workflow | not yet cloned — base: `Quiz Bot Dashboard`, id `MK076Yi7J2mknqi8` (kept in its existing `$env`+PostgREST form — no Postgres-credential version exists for this one) |
| New-subscriber notification | not yet located/ported — likely lives inside the original bot's live main workflow (`kWFvCbLnvWSdLtFq`) rather than as its own workflow; confirm exact source before porting |
| Error notification | reuse the existing shared workflow `❌ Error Notification` (id `XkT4TnNR4NHZRd6f`) via each new workflow's `settings.errorWorkflow` — no new clone needed, this one's already account-wide |
| Supabase schema | `matkovska_quiz_bot`, same project `cwtidnvbazepqkfweaed` — see `docs/quiz-bot-database.md` |
| Admin dashboard token | **generated** — value in local `.env` (`DASHBOARD_ADMIN_TOKEN`), gitignored. Never the original bot's `JNppNC8Vbj5s`. Not yet wired into a workflow (no dashboard workflow cloned yet) |
| Dashboard webhook paths | not yet chosen — must be NEW paths, distinct from the original bot's `quiz-dashboard`/`quiz-dashboard-api` (n8n webhook paths are unique per instance; the original bot's are already claimed on this same Hetzner instance) |
| Dashboard admin access | **both known**: Oleksandr (`863273840`, same identity as every other bot in this project family) and Matkovska (`5507304303`). Both go into: the shared admin token (already generated) for the dashboard webhook itself, and both chat_ids into the bot's per-chat `/dashboard` command scope + `Route Action`'s JS gate. Values in local `.env` |

**Note on repo visibility**: this repo is **public**. Confirmed via GitHub's API
(`private: false`) while handling the bot token above — this is *why* the token and admin token
live only in the gitignored local `.env`, never in a committed file. Keep this in mind for any
future doc here: chat_ids are fine to commit (not access-granting on their own, and the original
bot's own docs already do this), but bot tokens, admin tokens, and webhook shared secrets are not.

## Secrets handoff (manual steps — no tool covers these)

No MCP/API tool in this project can create an n8n credential or set a Coolify environment
variable — same limitation as every other bot in this family, and the reason the original bot's
secrets were always hand-entered by Oleksandr rather than moved by Claude. Both values below are
already generated and sitting in the local `.env`; what's left is entering them where the live
infrastructure actually reads them:

1. **Coolify → the N8N app resource → Environment Variables**: add
   `TELEGRAM_MATKOVSKA_BOT_TOKEN` = (value from local `.env`). No compose-file editing needed this
   time — `N8N_BLOCK_ENV_ACCESS_IN_NODE` is already `false` on this container from the original
   bot's setup. `Restart (pull latest)` (not plain `Restart`) is what actually applies it.
2. **n8n → Credentials → new credential, type "Telegram API"**: name it e.g. "Telegram - Matkovska
   Quiz Bot", paste the same token. This is what the cloned main workflow's `Telegram Trigger` node
   needs (it uses a real n8n credential, unlike the outgoing-send nodes which read `$env` directly).
3. When cloning the Postgres Edition workflow, point `Telegram Trigger`'s credential at the new
   credential from step 2, and update every raw-HTTP outgoing-send node's URL expression from
   `$env.TELEGRAM_QUIZ_BOT_TOKEN` to `$env.TELEGRAM_MATKOVSKA_BOT_TOKEN`.
4. The admin dashboard token (`DASHBOARD_ADMIN_TOKEN` in `.env`) goes directly into the cloned
   Dashboard workflow's two `Check Token` Code nodes (Page + API — both, matching the original's
   `ADMIN_TOKEN` constant in each) when that workflow is built.

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
