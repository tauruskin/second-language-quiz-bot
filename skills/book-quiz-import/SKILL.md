---
name: book-quiz-import
description: Turn photos/scans of pages from Matkovska's course book ("A Practical Guide for Learners of English" by Yanson, Svistun, Bogatyryeva, Lezhnyev) into vocab_words and grammar_questions rows for the Matkovska Quiz Bot's Supabase schema. Use this whenever the user shares book page images and wants vocabulary or quiz content pulled out of them, mentions "the book," "Phase 2 content," or asks to turn a unit/topic from the textbook into bot content — even if they don't use the word "extract" or name this skill directly.
---

# Book Quiz Import

Phase 2 of the Matkovska Quiz Bot (see this repo's `CLAUDE.md`) replaces the bot's generic
placeholder seed content with real content from Matkovska's own course book. This skill is that
replacement pipeline: it reads book page images, decides what's actually usable as bot content,
and produces a reviewable SQL script the human runs by hand — this project has no direct
database-write tool for content of this kind, and CLAUDE.md's rule 7 ("dry-run before anything
goes live") means generated content always gets a human look before it reaches real students.

## Where the source pages live

Scanned page images live in `book-source/` at the repo root — gitignored, local-only, never
committed (this is a scanned copyrighted textbook and the repo is public). Files are named after
the book's own printed page number, zero-padded: `page-0007.png` is the physical page with "7"
printed at the bottom. The folder fills in incrementally — don't assume every page exists; check
what's actually there with a directory listing before processing a unit, rather than assuming a
contiguous range.

When asked to process a unit or topic, find its page range in `book-source/` (ask the user for the
range if it's not obvious from context — units don't have a fixed page-count pattern, they vary a
lot in this book) and read those files with the Read tool directly. If pages the user wants aren't
in the folder yet, say so rather than working from a partial unit.

## The book has two very different kinds of content — know which one you're looking at

The book is a general university-level English course (phonetics + grammar + reading + speaking),
not a purpose-built quiz bank. Most of it doesn't fit a quiz bot at all. Before extracting
anything from a page, classify it:

**Usable, maps onto the schema:**
- **"Essential Vocabulary" boxes** — topic-clustered word lists (e.g. Unit 8's Entertainments/
  Leisure/Guest/Picnic under "WEEK-END"). This is the primary target — most of what this skill
  should produce comes from here.
- **Parenthetical-choice sentences** — e.g. "keep *(with, to)* the subject," "make *(over, up)* a
  story." A sentence with an embedded discrete choice and one correct answer — nearly a direct
  match for `grammar_questions`.
- **Vocabulary-in-context fill-ins** — numbered sentences like "She ___ her dream of becoming an
  actress," meant to be completed with a word from the unit's own vocabulary list.
- **Phonetics/transcription content** (Introductory Course units) — convertible to text-based
  multiple choice ("Which is the correct transcription of *teacher*?"), never to listening
  exercises. The bot has no audio-sending capability; don't design around one.

**Not usable as-is — skip these, don't force them into the schema:**
- Multi-blank cloze passages (a whole paragraph with a dozen blanks) — the schema holds one
  blank/question per row, not a passage.
- Ukrainian→English (or English→Ukrainian) translation exercises of full sentences or paragraphs —
  free-text translation has no reliable exact-match grading in a multiple-choice bot.
- Open-ended speaking/writing/discussion prompts, personal-info fill-in sheets, "make up a story,"
  "compare your own..." — nothing to grade against.
- Reading-comprehension questions tied to a specific passage — the bot sends one question with no
  surrounding context; a question that only makes sense next to a paragraph doesn't fit.
- Grammar theory tables/spelling rules on their own — these are reference material, not tasks.
  (They're still useful as *inspiration* if you're ever asked to author new gap-fill questions
  around a grammar point, just not as literal extraction targets.)

When a page is ambiguous, say so and ask rather than guessing — this list came from surveying real
pages with the project owner, but the book has more units than have been reviewed, and it will
keep surprising you.

## Target schema

Full DDL is in `docs/quiz-bot-database.md` — read it before writing any SQL, don't rely on the
summary below alone for exact column types/constraints.

**`vocab_words`**: `topic_id`, `topic_title`, `word`, `translation`, `example`, `transcription`,
`level`, `source`, `active`. Unique on `(topic_id, word)` — the same word can appear under
different topics, just not twice under the same one.

**`grammar_questions`**: `source_id`, `topic_id`, `topic_name`, `type` (`'gap-fill'` or
`'multiple-choice'` only), `difficulty`, `sentence`, `options` (array), `correct_option_index`,
`explanation`, `grammar_rule`, `level`, `source`, `active`. Unique on `(topic_id, source_id)`.

**Conventions specific to this book's content** (distinguishes it from the Phase 1 placeholder
seed, which used `source: 'import'`):
- `source: 'book-import'` on every row this skill produces.
- `level: 'B2'` — this book's actual difficulty (IPA transcription, allophone theory, philology
  terminology) reads well above the B1 placeholder content already in the schema. Don't default to
  `'B1'` just because that's what Phase 1 used.
- `topic_id`: one per **Main Course Unit**, not per Essential-Vocabulary sub-box — kebab-case slug
  of the unit's heading. Unit 8 "WEEK-END" → `topic_id: 'week-end'`, `topic_title: 'Week-End'`.
  This granularity was chosen deliberately: it's what a future "pick a unit to practice" bot menu
  would want to filter on (a real feature discussed but not yet built — don't build it as part of
  this skill, it needs its own design pass once there's actual content to filter).
- `source_id` for grammar_questions: `<topic-id>-<type-abbr>-<n>`, e.g. `week-end-mc-1`,
  `week-end-mc-2` — mirrors the `source_id` convention already used by the Phase 1 seed's grammar
  content (e.g. `vp-mc-1`), just scoped to this book's topics.

## The hard part: the book doesn't give you translation, example, or transcription

Essential Vocabulary boxes are just English words — no Ukrainian, no example sentence, no IPA. All
three are `not null` in the schema, so you have to generate them, not extract them. Treat this as
the highest-stakes part of the job:

- **Translation**: natural conversational Ukrainian a real language-department student would
  actually use — not a stiff dictionary gloss. If a word has multiple senses, pick the one that
  matches how the book uses it (check the unit's context, not just the bare word).
- **Example sentence**: a full, natural sentence using the word the way an English-department
  student would encounter it — not a dictionary-style minimal pair. Reuse the book's own sentence
  if the vocabulary box or a nearby exercise already provides one in context; only author a fresh
  one when it doesn't.
- **Transcription**: standard British RP IPA, using the same symbol set the book itself teaches in
  its Introductory Course units (short vowels ɪ e æ ɒ ʌ ʊ ə; long vowels iː ɑː ɔː uː ɜː; diphthongs
  eɪ aɪ ɔɪ əʊ aʊ ɪə eə ʊə) — don't introduce a different transcription convention than the one the
  student is being taught elsewhere in the same book.

Because this is generated content feeding real students at a real language department, flag it
clearly in whatever summary you give the human before they run the SQL — call out a few
translations/examples explicitly so a native-Ukrainian-speaking reviewer can spot-check quality
quickly, don't just say "generated N rows" and move on.

## Extracting the secondary grammar-adjacent content

Keep this genuinely secondary — the project owner was explicit that vocabulary is the priority and
these shouldn't dominate the output:

- **Parenthetical-choice sentences** → `type: 'multiple-choice'`. The sentence becomes `sentence`
  (join any lead-in context the way the Phase 1 seed's multiple-choice rows do — check
  `docs/quiz-bot-database.md`'s comment on that column), the parenthetical options become
  `options`, the one that's grammatically correct is `correct_option_index`. Author a genuine
  `explanation` and `grammar_rule` even though the book doesn't spell one out for these — that's
  expected authorship, not extraction, same as the sibling project's own grammar-question pipeline
  does.
- **Vocabulary-in-context fill-ins** → `type: 'gap-fill'`. The numbered sentence becomes `sentence`
  with `___` where the blank is. Build `options` from the unit's own Essential Vocabulary list:
  the correct word plus 3 plausible-but-wrong words from the *same* topic (so the wrong answers are
  at least thematically relevant, not random).
- **Phonetics-as-text** → `type: 'multiple-choice'`. E.g. "Which is the correct transcription of
  *teacher*?" with the real transcription plus 3 plausible near-miss IPA strings (wrong stress
  placement, wrong vowel length, one wrong phoneme) as distractors.

## Output

Write a `.sql` file to `scripts/book-import/<topic-id>.sql` (create the directory if it doesn't
exist) in the same `insert into ... values (...), (...), ...;` style as
`docs/quiz-bot-database.md`'s "Phase 1 content seed" section — one statement per table, all rows
for that unit in one run. Don't insert directly; this repo's convention (and CLAUDE.md rule 7) is
generate → human reviews → human runs it in the Supabase SQL editor.

After writing the file, tell the human: the file path, a row count per table, and a handful of the
actual generated translations/examples inline in your message (not just "check the file") so
reviewing doesn't require them to go open a separate file first.

## Worked example

Given Unit 8's "WEEK-END" Essential Vocabulary box (Entertainments: cinema, circus, club, dance
hall/studio...) and its parenthetical-choice exercise, a correct first few rows would look like:

```sql
insert into matkovska_quiz_bot.vocab_words
  (topic_id, topic_title, word, translation, example, transcription, level, source, active)
values
  ('week-end', 'Week-End', 'cinema', 'кінотеатр', 'We went to the cinema to watch the new film.', 'ˈsɪnəmə', 'B2', 'book-import', true),
  ('week-end', 'Week-End', 'discotheque', 'дискотека', 'They danced all night at the discotheque.', 'ˈdɪskətek', 'B2', 'book-import', true);

insert into matkovska_quiz_bot.grammar_questions
  (source_id, topic_id, topic_name, type, difficulty, sentence, options, correct_option_index, explanation, grammar_rule, level, source, active)
values
  ('week-end-mc-1', 'week-end', 'Week-End', 'multiple-choice', 'medium',
   'Look ___ the words in the dictionary.',
   array['about', 'up'], 1,
   '"Look up" means to search for information in a reference source; "look about" means to glance around.',
   'phrasal verb: look up vs. look about', 'B2', 'book-import', true);
```

Note the translations and transcriptions above are illustrative for this skill file — always
generate real ones from the actual page content you're given, following the quality guidance
above, not copied verbatim from here.
