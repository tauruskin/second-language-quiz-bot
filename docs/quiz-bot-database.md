# Contract: Matkovska Quiz Bot Database Schema (Supabase)

Authoritative DDL for this bot's data — schema `matkovska_quiz_bot`, in the **same Supabase
project** that backs `app-englishpusher` and the original Quiz Bot's `quiz_bot` schema
(`cwtidnvbazepqkfweaed`). Same account, same instance, own project decision — see
`docs/superpowers/specs/2026-08-18-matkovska-quiz-bot-design.md` for why. Run once in the Supabase
SQL editor. Any schema change updates this file first (same convention as the original bot's
`quiz-bot-database.md` in `moodle-task-builder`).

This file is a **consolidated initial deploy**, not a migration history — unlike the original
bot's contract doc, there's no prior live state to preserve, so this is the terminal schema shape
directly (equivalent to the original's base DDL + its grammar-questions + trivia-sessions +
signup-hour-default + personal-trend-scoping migrations, all folded into one script), plus the
dashboard's backing views/functions (originally specified in a separate design doc over there,
`docs/superpowers/specs/2026-08-16-quiz-bot-teacher-dashboard-design.md`) and the
`subscribers.dashboard_token` column — **both of which are missing from the original repo's own
`quiz-bot-database.md`, discovered while preparing this schema.** Worth fixing over there too at
some point; not done as part of this repo.

**No RLS on these tables**, same reasoning as the original: this schema is touched only by n8n's
service-role key, no browser/anon access path exists. Isolation comes entirely from `GRANT`s —
only `service_role` gets any privilege on `matkovska_quiz_bot`.

## Initial schema

```sql
create extension if not exists pgcrypto;

create schema if not exists matkovska_quiz_bot;

create table matkovska_quiz_bot.vocab_words (
  id            bigint generated always as identity primary key,
  topic_id      text not null,
  topic_title   text not null,
  word          text not null,
  translation   text not null,
  example       text not null,
  transcription text,
  level         text not null default 'B1',
  source        text not null default 'import',
  active        boolean not null default true,
  created_at    timestamptz not null default now(),
  unique (topic_id, word)
);

create table matkovska_quiz_bot.grammar_questions (
  id                    bigint generated always as identity primary key,
  source_id             text not null,  -- id string from the source repo, e.g. 'irr-v-gap-1'
  topic_id              text not null,
  topic_name            text not null,
  type                  text not null check (type in ('gap-fill', 'multiple-choice')),
  difficulty            text not null,
  sentence              text not null,  -- gap-fill: contains ___; multiple-choice: context + question, joined
  options               text[] not null,
  correct_option_index  smallint not null,
  explanation           text not null,
  grammar_rule          text not null,
  level                 text not null default 'B1',
  source                text not null default 'import',
  active                boolean not null default true,
  created_at            timestamptz not null default now(),
  unique (topic_id, source_id)
);

create table matkovska_quiz_bot.subscribers (
  chat_id         bigint primary key,
  first_name      text not null default '',
  cadence         text not null default 'daily' check (cadence in ('daily','weekly')),
  -- Defaults to the subscriber's own signup hour (Kyiv time), not a fixed hour, so growth doesn't
  -- pile the whole scheduled batch onto one hour - same fix the original bot needed after the fact.
  send_hour       smallint not null default (extract(hour from now() at time zone 'Europe/Kyiv'))::smallint
                    check (send_hour between 0 and 23),
  send_day        smallint check (send_day between 0 and 6),  -- 0=Sunday, matches Postgres EXTRACT(DOW); null unless cadence='weekly'
  content_pref    text not null default 'both' check (content_pref in ('vocab', 'grammar', 'both')),
  active          boolean not null default true,
  last_sent_at    timestamptz,
  -- Personal dashboard access token (10 hex chars from 5 random bytes). UNIQUE is a safety
  -- addition on top of what memory records for the original bot's column - not confirmed present
  -- there, but strictly closes a token-collision edge case at zero cost.
  dashboard_token text not null unique default encode(gen_random_bytes(5), 'hex'),
  created_at      timestamptz not null default now()
);

create table matkovska_quiz_bot.answers (
  id            bigint generated always as identity primary key,
  chat_id       bigint not null references matkovska_quiz_bot.subscribers(chat_id) on delete cascade,
  -- Points at vocab_words.id when content_type='vocab', grammar_questions.id when 'grammar'.
  -- No FK - Postgres can't FK one column to two tables. Same trust model as everywhere else in
  -- this schema (service-role-only writes, no RLS).
  question_id   bigint not null,
  content_type  text not null check (content_type in ('vocab', 'grammar')),
  correct       boolean not null,
  answered_at   timestamptz not null default now()
);
create index on matkovska_quiz_bot.answers (chat_id, question_id);

-- Per-subscriber round state. A row's existence IS "a round is in progress" - no separate
-- active/status flag to keep in sync. Deleted when a round completes.
create table matkovska_quiz_bot.sessions (
  chat_id            bigint primary key references matkovska_quiz_bot.subscribers(chat_id) on delete cascade,
  question_index     smallint not null default 1 check (question_index between 1 and 3),
  correct_count      smallint not null default 0,
  asked_vocab_ids    bigint[] not null default '{}',
  asked_grammar_ids  bigint[] not null default '{}',
  started_at         timestamptz not null default now()
);

-- Isolation: service_role only. anon/authenticated get nothing on this schema.
grant usage on schema matkovska_quiz_bot to service_role;
grant all on all tables in schema matkovska_quiz_bot to service_role;
grant all on all sequences in schema matkovska_quiz_bot to service_role;
alter default privileges in schema matkovska_quiz_bot grant all on tables to service_role;
alter default privileges in schema matkovska_quiz_bot grant all on sequences to service_role;

create or replace function matkovska_quiz_bot.due_subscribers()
returns setof matkovska_quiz_bot.subscribers
language sql stable
as $$
  select *
  from matkovska_quiz_bot.subscribers
  where active
    and send_hour = extract(hour from now() at time zone 'Europe/Kyiv')::smallint
    and (
      (cadence = 'daily'
        and (last_sent_at is null
             or (last_sent_at at time zone 'Europe/Kyiv')::date
                <> (now() at time zone 'Europe/Kyiv')::date))
      or
      (cadence = 'weekly'
        and send_day = extract(dow from now() at time zone 'Europe/Kyiv')::smallint
        and (last_sent_at is null or last_sent_at < now() - interval '6 days'))
    );
$$;

create or replace function matkovska_quiz_bot.pick_next_question(p_chat_id bigint, p_exclude_ids bigint[] default '{}')
returns table (word_id bigint, word text, correct text, distractors text[])
language plpgsql
as $$
declare
  v_word_id bigint;
  v_word text;
  v_translation text;
  v_topic_id text;
begin
  select w.id, w.word, w.translation, w.topic_id
    into v_word_id, v_word, v_translation, v_topic_id
  from matkovska_quiz_bot.vocab_words w
  where w.active and w.level = 'B1'
    and not (w.id = any(p_exclude_ids))
    and not exists (
      select 1 from matkovska_quiz_bot.answers a
      where a.chat_id = p_chat_id and a.content_type = 'vocab' and a.question_id = w.id
    )
  order by random()
  limit 1;

  if v_word_id is null then
    select w.id, w.word, w.translation, w.topic_id
      into v_word_id, v_word, v_translation, v_topic_id
    from matkovska_quiz_bot.vocab_words w
    where w.active and w.level = 'B1'
      and not (w.id = any(p_exclude_ids))
      and (
        select a.correct from matkovska_quiz_bot.answers a
        where a.chat_id = p_chat_id and a.content_type = 'vocab' and a.question_id = w.id
        order by a.answered_at desc limit 1
      ) = false
    order by random()
    limit 1;
  end if;

  if v_word_id is null then
    select w.id, w.word, w.translation, w.topic_id
      into v_word_id, v_word, v_translation, v_topic_id
    from matkovska_quiz_bot.vocab_words w
    join matkovska_quiz_bot.answers a
      on a.question_id = w.id and a.chat_id = p_chat_id and a.content_type = 'vocab'
    where w.active and w.level = 'B1'
      and not (w.id = any(p_exclude_ids))
    order by a.answered_at asc
    limit 1;
  end if;

  if v_word_id is null then
    return;
  end if;

  return query
  select v_word_id, v_word, v_translation,
    array(
      select translation from matkovska_quiz_bot.vocab_words
      where topic_id = v_topic_id and id <> v_word_id and active
      order by random() limit 3
    );
end;
$$;

create or replace function matkovska_quiz_bot.pick_next_grammar_question(p_chat_id bigint, p_exclude_ids bigint[] default '{}')
returns table (question_id bigint, sentence text, options text[], correct_option_index smallint, explanation text)
language plpgsql
as $$
declare
  v_id bigint;
begin
  select q.id into v_id
  from matkovska_quiz_bot.grammar_questions q
  where q.active and q.level = 'B1'
    and not (q.id = any(p_exclude_ids))
    and not exists (
      select 1 from matkovska_quiz_bot.answers a
      where a.chat_id = p_chat_id and a.content_type = 'grammar' and a.question_id = q.id
    )
  order by random()
  limit 1;

  if v_id is null then
    select q.id into v_id
    from matkovska_quiz_bot.grammar_questions q
    where q.active and q.level = 'B1'
      and not (q.id = any(p_exclude_ids))
      and (
        select a.correct from matkovska_quiz_bot.answers a
        where a.chat_id = p_chat_id and a.content_type = 'grammar' and a.question_id = q.id
        order by a.answered_at desc limit 1
      ) = false
    order by random()
    limit 1;
  end if;

  if v_id is null then
    select q.id into v_id
    from matkovska_quiz_bot.grammar_questions q
    join matkovska_quiz_bot.answers a
      on a.question_id = q.id and a.chat_id = p_chat_id and a.content_type = 'grammar'
    where q.active and q.level = 'B1'
      and not (q.id = any(p_exclude_ids))
    order by a.answered_at asc
    limit 1;
  end if;

  if v_id is null then
    return;
  end if;

  return query
  select q.id, q.sentence, q.options, q.correct_option_index, q.explanation
  from matkovska_quiz_bot.grammar_questions q
  where q.id = v_id;
end;
$$;

-- Current streak: count of consecutive correct answers, most recent first.
create or replace function matkovska_quiz_bot.current_streak(p_chat_id bigint)
returns int
language sql stable
as $$
  with ordered as (
    select correct, row_number() over (order by answered_at desc) as rn
    from matkovska_quiz_bot.answers
    where chat_id = p_chat_id
  ),
  first_wrong as (
    select min(rn) as rn from ordered where correct = false
  )
  select coalesce(
    (select rn - 1 from first_wrong),
    (select count(*)::int from ordered)
  );
$$;

-- One row per subscriber: accuracy, streak, activity. Backs the dashboard roster + /mystats.
create or replace view matkovska_quiz_bot.dashboard_student_summary as
select
  s.chat_id,
  s.first_name,
  s.cadence,
  s.content_pref,
  s.active,
  s.created_at as subscribed_since,
  s.last_sent_at,
  count(a.id) as total_answered,
  count(a.id) filter (where a.correct) as total_correct,
  case when count(a.id) = 0 then null
       else round(100.0 * count(a.id) filter (where a.correct) / count(a.id), 1)
  end as accuracy_pct,
  max(a.answered_at) as last_answered_at,
  matkovska_quiz_bot.current_streak(s.chat_id) as current_streak
from matkovska_quiz_bot.subscribers s
left join matkovska_quiz_bot.answers a on a.chat_id = s.chat_id
group by s.chat_id, s.first_name, s.cadence, s.content_pref, s.active, s.created_at, s.last_sent_at;

-- Vocab + grammar topics unioned into one error-rate ranking. Backs the dashboard's topic chart/table.
create or replace view matkovska_quiz_bot.dashboard_topic_breakdown as
select 'vocab' as content_type, w.topic_id, w.topic_title as topic_label,
  count(a.id) as total_attempts,
  count(a.id) filter (where a.correct) as total_correct,
  round(100.0 * count(a.id) filter (where not a.correct) / nullif(count(a.id), 0), 1) as error_rate_pct,
  count(distinct a.chat_id) as distinct_students
from matkovska_quiz_bot.answers a
join matkovska_quiz_bot.vocab_words w on w.id = a.question_id and a.content_type = 'vocab'
group by w.topic_id, w.topic_title
union all
select 'grammar' as content_type, g.topic_id, g.topic_name as topic_label,
  count(a.id) as total_attempts,
  count(a.id) filter (where a.correct) as total_correct,
  round(100.0 * count(a.id) filter (where not a.correct) / nullif(count(a.id), 0), 1) as error_rate_pct,
  count(distinct a.chat_id) as distinct_students
from matkovska_quiz_bot.answers a
join matkovska_quiz_bot.grammar_questions g on g.id = a.question_id and a.content_type = 'grammar'
group by g.topic_id, g.topic_name;

-- Daily accuracy/volume trend, Kyiv-day-bucketed to match due_subscribers()'s own convention.
-- p_chat_id null = cohort-wide (admin view); a real chat_id scopes to one subscriber (/mystats).
create or replace function matkovska_quiz_bot.dashboard_trends(p_days int default 30, p_chat_id bigint default null)
returns table (day date, total_answers bigint, total_correct bigint, accuracy_pct numeric, active_students bigint)
language sql stable
as $$
  select (a.answered_at at time zone 'Europe/Kyiv')::date as day,
    count(*), count(*) filter (where a.correct),
    round(100.0 * count(*) filter (where a.correct) / count(*), 1),
    count(distinct a.chat_id)
  from matkovska_quiz_bot.answers a
  where a.answered_at >= now() - (p_days || ' days')::interval
    and (p_chat_id is null or a.chat_id = p_chat_id)
  group by 1
  order by 1;
$$;

-- One student's full history, for the dashboard's drill-down view.
create or replace function matkovska_quiz_bot.dashboard_student_detail(p_chat_id bigint)
returns table (answered_at timestamptz, content_type text, topic_label text, question_text text, correct boolean)
language sql stable
as $$
  select a.answered_at, a.content_type,
    coalesce(w.topic_title, g.topic_name),
    coalesce(w.word, g.sentence),
    a.correct
  from matkovska_quiz_bot.answers a
  left join matkovska_quiz_bot.vocab_words w on a.content_type = 'vocab' and w.id = a.question_id
  left join matkovska_quiz_bot.grammar_questions g on a.content_type = 'grammar' and g.id = a.question_id
  where a.chat_id = p_chat_id
  order by a.answered_at desc;
$$;

grant execute on all functions in schema matkovska_quiz_bot to service_role;
alter default privileges in schema matkovska_quiz_bot grant execute on functions to service_role;
grant select on matkovska_quiz_bot.dashboard_student_summary, matkovska_quiz_bot.dashboard_topic_breakdown to service_role;
```

## Phase 1 content seed (copy from the original bot's schema)

Same Supabase project, so this is a same-database cross-schema copy — no export/import step, no
re-running the original curation import scripts. Run once, after the schema above exists. Requires
a role with `select` on `quiz_bot` (the Supabase SQL editor's own session role, not `service_role`,
already has this — this statement is meant to be run by hand, not by n8n).

```sql
insert into matkovska_quiz_bot.vocab_words
  (topic_id, topic_title, word, translation, example, transcription, level, source, active)
select topic_id, topic_title, word, translation, example, transcription, level, 'import', active
from quiz_bot.vocab_words;

insert into matkovska_quiz_bot.grammar_questions
  (source_id, topic_id, topic_name, type, difficulty, sentence, options, correct_option_index,
   explanation, grammar_rule, level, source, active)
select source_id, topic_id, topic_name, type, difficulty, sentence, options, correct_option_index,
   explanation, grammar_rule, level, 'import', active
from quiz_bot.grammar_questions;
```

Replaced wholesale in Phase 2, once Matkovska's book is processed: deactivate (`active = false`)
or delete these seed rows and insert the book-derived ones instead. Exact swap procedure to be
decided when Phase 2 is designed — depends on whether any real students will have answered seed
questions by then (if so, prefer deactivating over deleting, so `answers` rows don't dangle).

## Auth configuration (Supabase dashboard, not SQL)

| Setting | Value |
|---|---|
| Settings → API → Exposed schemas | add `matkovska_quiz_bot` (PostgREST only serves schemas listed here — this schema is invisible to `/rest/v1/...` until added, same as `quiz_bot` needed the same step) |

**Adding `matkovska_quiz_bot` to Exposed schemas makes it available — it does not make it the
default.** `public` stays the default; `quiz_bot` (the original bot) is unaffected. Every request
against `matkovska_quiz_bot` from a PostgREST-style n8n node MUST send an explicit profile header
or PostgREST serves `public` instead and 404s: `Accept-Profile: matkovska_quiz_bot` on GET,
`Content-Profile: matkovska_quiz_bot` on POST/PATCH/DELETE (including RPC calls, which are POST).
Postgres-credential-style n8n nodes (native `n8n-nodes-base.postgres`) don't need this header —
isolation there is just the schema-qualified table/function names already written into every query
above.

## Invariants

- No RLS on `matkovska_quiz_bot` tables — isolation is via `GRANT`s to `service_role` only.
- `vocab_words`/`grammar_questions` are keyed so a future re-import (Phase 2) can be idempotent.
- `subscribers.send_day` uses Postgres's own `EXTRACT(DOW ...)` convention (0=Sunday..6=Saturday).
- Every PostgREST-style call against this schema MUST send `Accept-Profile`/`Content-Profile:
  matkovska_quiz_bot` — omitting it doesn't error loudly, it silently targets `public` and 404s.
- **`service_role` has access to every schema in this Supabase project**, including `quiz_bot` and
  `public`. Nothing at the credential level stops an n8n node from accidentally reading/writing the
  wrong teacher's schema — the only thing that does is every node's own query/header actually
  saying `matkovska_quiz_bot`. Verify this explicitly when cloning workflows (see the design spec
  and runbook) rather than trusting a copy-paste got every reference.
