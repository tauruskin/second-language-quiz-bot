---
name: book-quiz-import
description: Turn photos/scans of pages from Matkovska's course book ("A Practical Guide for Learners of English" by Yanson, Svistun, Bogatyryeva, Lezhnyev) into vocab_words and grammar_questions rows for the Matkovska Quiz Bot's Supabase schema. Use this whenever the user shares book page images and wants vocabulary or quiz content pulled out of them, mentions "the book," "Phase 2 content," or asks to turn a unit/topic from the textbook into bot content — even if they don't use the word "extract" or name this skill directly.
---

# Book Quiz Import

Phase 2 of the Matkovska Quiz Bot (see this repo's `CLAUDE.md`) replaces the bot's generic
placeholder seed content with real content from Matkovska's own course book. This skill is that
replacement pipeline: it reads book page images, decides what's actually usable as bot content,
gets it in front of the human for review, and — once approved — inserts it into Supabase directly
(see "Output" below for how). CLAUDE.md's rule 7 ("dry-run before anything goes live") is honored
by the review step, not by avoiding direct writes altogether: generated content always gets a
human look at real sample rows before it reaches real students, but nothing here requires the
human to hand-paste SQL themselves.

## Where the source pages live

Scanned page images live in `book-source/` at the repo root — gitignored, local-only, never
committed (this is a scanned copyrighted textbook and the repo is public). Files are grouped into
one subfolder per unit/section (e.g. `book-source/unit-01-family/`,
`book-source/introductory-course/`, `book-source/writing-section/`) — this replaced an earlier
flat layout once it became clear a single 300+ page folder made it too easy to lose track of which
pages belonged to which unit. When new pages come in for a unit that doesn't have a folder yet,
create one using the same `unit-NN-<topic-slug>` pattern (zero-padded unit number so folders sort
correctly) or a descriptive slug for non-Main-Course sections.

Within each folder, files are named by scan/photo sequence, zero-padded — **not** reliably by the
book's own printed page number; see the offset note below. The folder fills in incrementally —
don't assume every page of a unit exists yet; check what's actually there with a directory listing
before processing a unit, rather than assuming a contiguous range.

When asked to process a unit or topic, find (or ask the human to confirm) which subfolder it's in,
list what's there, and read those files with the Read tool directly. If pages the user wants aren't
in the folder yet, say so rather than working from a partial unit.

**The filename's page number is not the number printed on the page — there's a consistent offset,
not a drift.** For the first big scanned range (files `0003`-`0085`), printed page = file number +
4 throughout (confirmed at six points spread across the whole range, including both ends) — most
likely because the scan starts a few pages after the book's actual page 1, skipping unnumbered
front matter (cover, title page, etc.), so the file sequence sits consistently behind the printed
numbers. An earlier version of this note wrongly described this as a "drift appearing partway
through the range" based on a misread page — it isn't a drift, it's a fixed offset from the start
of that range. **Always read the number actually printed at the bottom of the page** for anything
you cite back to the user or write into a comment — don't compute it from the filename, and don't
assume the +4 offset found in this range holds for other scanned ranges (each batch of pages may
have been scanned separately, with its own offset or none at all) without checking a page or two
directly.

## Before extracting anything: map the whole unit

A unit's usable content is almost never in one place. Unit 1 ("Family," ~30 pages) turned out to
have vocabulary-bearing material in at least six distinct spots, non-contiguous, mixed in with
long stretches of open-ended reading/speaking content that isn't usable at all: an "ESSENTIAL
VOCABULARY" box (Relationship + Occupation), a "MAN'S APPEARANCE AND CHARACTER" word-list section
(a different shape — flowing lists under sub-headings, not a boxed grid), a "Phrases and Word
Combinations" idiom-gloss section, "CULTURE CONTEXT" idiom-glosses tied to a reading passage,
inline "Notes:" idiom-glosses tied to a *different* reading passage, and three separate exercises
(a definition-riddle set, an antonym-matching set, an odd-one-out set) buried inside otherwise
open-ended "CHECK YOUR GRAMMAR" sections. Stopping after finding the first Essential Vocabulary
box — the obvious, expected source — would have missed most of the unit's actual content.

So: read through *every* page of the unit before generating anything, and keep a running list of
every vocab-bearing section and every grammar-adjacent exercise you find, with its page number.
Only start generating SQL once you've read the whole unit and have that list in front of you —
otherwise you'll anchor on the first thing you find and miss the rest.

**Recognize where the unit actually ends, don't assume it from page count.** Some section headers
recur near the end of *multiple* units and don't signal a new unit starting — "ENVIRONMENTAL
THINKING AND LIFE STYLE" appeared this way at the end of both Unit 1 and Unit 3, each time
introducing an unrelated reading passage before the unit actually closed. The real signal that a
unit has ended is the next "UNIT N" banner (Introductory Course) or the next bolded unit title
under "Main Course" — check for that explicitly rather than guessing from how much you've already
read.

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
- **Definition riddles** ("Someone whose job is to design buildings," expecting the reader to name
  the word) → `type: 'multiple-choice'`. The riddle text becomes `sentence`; `options` is the
  correct word plus 3 distractors pulled from the *same* vocabulary list the riddle set belongs to
  (e.g. other occupations from the unit's own Essential Vocabulary box) — real near-miss options,
  not random words. If two list-words could both plausibly answer the same riddle, skip that one
  rather than forcing an ambiguous question; don't try to salvage every riddle in a set.
- **Antonym-matching exercises** (two columns, "match A with its opposite in B") → `type:
  'multiple-choice'`, one row per pair: `sentence: "What is the opposite of '<word>'?"`, `options`
  the correct opposite plus 3 other words from column B. Work out the pairing yourself if the book
  doesn't spell it out one-to-one — some words can plausibly pair with more than one opposite
  (e.g. both "plain" and "ugly" could oppose "handsome"/"attractive"); pick distinct, defensible
  pairs so nothing in column B gets reused unless the book's own answer key clearly intends that.
- **Odd-one-out exercises** (a group of 5-6 words, one doesn't belong) → `type: 'multiple-choice'`,
  `sentence: "Which word does not belong in this group: <the words>?"`, `options` are all the words
  in the group (so this is one of the few cases where `options` may have 5-6 entries, not 4),
  `correct_option_index` the odd one, with `explanation` stating the actual reasoning (same
  part-of-speech-but-one, same-polarity-but-one, same-category-but-one, etc.) rather than just
  asserting an answer.

## Output and how content actually gets into Supabase

In practice this project's real Supabase credentials (`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`)
are available as genuine shell environment variables — check `env | grep -i supabase` rather than
assuming they're missing just because there's no `.env` entry (an older assumption in this repo's
`CLAUDE.md` turned out to be wrong). That makes direct PostgREST inserts possible, which is faster
and less error-prone than asking the human to hand-paste a large SQL file, and is what actually
happened for every batch processed so far. The validated workflow:

1. Generate the batch (translations/examples/questions) and show the human a representative sample
   inline in your message — a handful of actual rows, not just a row count — per CLAUDE.md rule 7's
   dry-run principle. Wait for their go-ahead before writing anything to the database.
2. On approval, insert via `POST {SUPABASE_URL}/rest/v1/vocab_words` (or `/grammar_questions`),
   headers `apikey`, `Authorization: Bearer <key>`, `Content-Profile: matkovska_quiz_bot`,
   `Content-Type: application/json`, `Prefer: return=representation`. Write a small Node script
   (`fetch`, no dependencies) rather than trying to escape Ukrainian text and apostrophes through
   inline bash/curl — that's genuinely error-prone at this volume.
3. Write/append to `scripts/book-import/<topic-id>.sql`, in the same `insert into ... values
   (...), (...), ...;` style as `docs/quiz-bot-database.md`'s "Phase 1 content seed" section. This
   file is a **mirror of what's actually live**, matching this repo's general "repo mirrors live
   state" convention — not a pre-insertion artifact the human runs by hand. One `-- Batch N: ...`
   comment block per session, noting the source pages and what's in it, appended (never
   overwritten) as more content gets added to the same topic over time.
4. Commit the `.sql` file (never `book-source/` — that stays gitignored).

For large batches (a full unit's worth of vocabulary can easily be 100+ rows across several
sub-sections), do your own page-reading and mapping first, then hand the actual bulk
translation-generation + insertion + file-update work to a subagent — give it the exact source
text you already transcribed from the images (so it isn't re-reading files itself) plus the exact
schema/quality conventions from this file. This keeps translation-quality judgment in a fresh,
focused context rather than competing with a long mapping/exploration history. Independently
re-verify its work afterward (see the checklist below) rather than trusting its self-report —
that's exactly how the Occupation-list gap below was caught.

## Before declaring a unit done

Run this checklist before telling the human a unit is complete — the whole point is catching gaps
before they go unnoticed, not after:

- Re-fetch the actual live row counts for the topic from Supabase yourself; don't just trust an
  insert response or a subagent's reported count.
- Check for duplicate `word` values within the topic (`vocab_words`) and duplicate `source_id`
  values within the topic (`grammar_questions`) — the unique constraints will reject true
  duplicates, but near-duplicates with slightly different wording won't error and are easy to miss.
- Spot-check a handful of actual stored rows (not the generation output you already saw) — confirm
  what's in the database matches what was reviewed.
- Confirm the `.sql` file's content matches the live database exactly.
- **Explicitly ask: did any word list get used as material for something else (e.g. as the
  distractor pool for definition-riddle questions) without also being inserted as its own
  `vocab_words` batch?** This exact gap happened on the first full-unit run — the Occupation list
  was used to build riddle distractors and answer them, but the words themselves were never
  inserted until a second pass caught it. "I used this list" is not the same as "I extracted this
  list."

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
