# `/about` command — design

**Status:** Approved 2026-08-19, ready for implementation planning.

## Goal

Add a `/about` command to the Matkovska Quiz Bot (`O72qRKsNQWGic1xp`, "Matkovska - Telegram Quiz
Bot (Postgres Edition)") that tells students what the bot is, who runs it, and how their data is
used — the "teacher and bot policy" information called for when Phase 1 shipped.

## Context

Phase 1 is live (see `docs/telegram-bot-runbook.md`). The bot already has a `/help` command
(`Reply: Help`, a plain-text `httpRequest` node with no links) and two link-sending nodes,
`Reply: Dashboard Link` and `My Stats Link`, which use `parse_mode: 'HTML'` with a real `<a
href="...">` anchor. `/about` needs a link (to the university's homepage), so it follows the
link-sending pattern, not the plain-text `/help` pattern.

## Decisions

- **Trigger:** slash command only (`/about`), no inline button. Same visibility as `/help` — not
  admin-gated, works for every subscriber.
- **Content:** hardcoded directly in the new node's code, same as every other reply node in this
  bot. Not fetched from Supabase — this text changes rarely enough that editing the workflow when
  it does is simpler than adding a settings table + an extra DB read on every call.
- **No personalization** — identical message for every chat_id, admins included.

## Implementation

Three changes to the existing main bot workflow, all additive (no existing node's behavior
changes):

1. **`Route`** (Code node) — add one more branch to the action-detection `if`/`else if` chain:
   ```js
   else if (/^\/about\b/i.test(t)) action = 'about';
   ```
   Placement: alongside the other simple slash-command branches (`/start`, `/settings`, `/pause`,
   `/resume`, `/question`, `/dashboard`, `/mystats`), before the `su_*`/`qz_*` callback-data
   branches.

2. **`Route Action`** (switch node, currently 14 rules) — add a 15th rule:
   ```json
   {
     "conditions": {
       "options": { "version": 2 },
       "combinator": "and",
       "conditions": [{
         "operator": { "type": "string", "operation": "equals" },
         "leftValue": "={{ $json.action }}",
         "rightValue": "about"
       }]
     },
     "outputKey": "about"
   }
   ```
   Wire its output to the new `Reply: About` node.

3. **`Reply: About`** (new `n8n-nodes-base.httpRequest` node, typeVersion 4.2, cloned in structure
   from `Reply: Dashboard Link`/`My Stats Link`'s Telegram-send shape but as a plain `httpRequest`
   node like `Reply: Help`, not a Code node — no branching logic needed, just a static send):
   ```
   POST https://api.telegram.org/bot{{ $env.TELEGRAM_MATKOVSKA_BOT_TOKEN }}/sendMessage
   body: {
     chat_id: Number($('Route').item.json.chat_id),
     text: "<the finalized copy below, with the university link as an HTML anchor>",
     parse_mode: "HTML"
   }
   ```

   Finalized message text (HTML entities/anchor as they'll actually be sent):
   ```
   🎓 This bot delivers English language quizzes for students of Kamianets-Podilskyi Ivan Ohienko National University, German-English Department.

   👩‍🏫 Created and managed by Mariya Matkovska.

   📚 You'll receive tasks daily/weekly to practice vocabulary and grammar.

   📊 Your results are used to track your progress and may be shared with your instructor.

   🔗 University page: <a href="https://kpnu.edu.ua/">kpnu.edu.ua</a>

   Good luck! 🍀
   ```

4. **Command menu** — add `{"command":"about","description":"About this bot"}` to all three
   `setMyCommands` calls already run for this bot: the default (no-scope) list and both admin
   chat-scoped lists (`863273840`, `5507304303`). Placement: after `help`, matching the order it
   appears in `/help`'s own text if that's ever updated to mention it (not required by this spec,
   just a nicety — not doing it now, out of scope).

## Out of scope

- Editing `/help`'s own text to mention `/about` exists (nice-to-have, not required).
- Any Supabase-backed editable content.
- Inline button / persistent keyboard entry point.
- Localization (bot is English-only throughout already).

## Testing plan

1. Send `/about` from a real chat (Oleksandr's `863273840`). Confirm the message arrives, the
   university link renders as a tappable link (not a raw URL), and emoji render correctly.
2. `getMyCommands` (default scope) — confirm `about` is present.
3. `getMyCommands` (chat-scoped, `863273840`) — confirm `about` is present alongside `dashboard`.
4. Re-export the updated workflow JSON to `scripts/n8n/matkovska-telegram-quiz-bot.json` and
   commit, per this repo's "mirrors live n8n state" rule.
