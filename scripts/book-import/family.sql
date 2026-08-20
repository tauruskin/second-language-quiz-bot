-- Book import: Main Course Unit 1 ("Family", inferred topic title - no explicit unit banner was
-- visible on the pages read; content is clearly about family relations/marriage, but confirm this
-- title before running if you'd prefer something else).
--
-- Source: book-source/a-practical-guide-for-learners-of-english-Yanson_page-0084.jpg (printed
-- page 88) and _page-0085.jpg (printed page 89) - the "Notes:" phrase glossary attached to the
-- reading excerpt from W.S. Maugham's "The Painted Veil".
--
-- These are idiomatic phrases, not single words - the book supplies the phrase + an English
-- definition; translation and example below are generated (not extracted), per
-- skills/book-quiz-import/SKILL.md. transcription is left null - IPA doesn't meaningfully apply to
-- multi-word idioms the way it does to single vocabulary words.
--
-- REVIEW BEFORE RUNNING. This is a first test batch, not yet confirmed against the full skill.

insert into matkovska_quiz_bot.vocab_words
  (topic_id, topic_title, word, translation, example, transcription, level, source, active)
values
  ('family', 'Family', 'to be fond of someone',
   'любити когось, мати теплі почуття до когось',
   'I''m really fond of my grandmother; she always tells the best stories.',
   null, 'B2', 'book-import', true),

  ('family', 'Family', 'to hold oneself erect',
   'триматися прямо, тримати рівну поставу',
   'The old soldier still held himself erect despite his age.',
   null, 'B2', 'book-import', true),

  ('family', 'Family', 'to advance oneself',
   'просуватися по службі, вдосконалюватися',
   'He worked hard every evening, hoping to advance himself at the company.',
   null, 'B2', 'book-import', true),

  ('family', 'Family', 'to achieve something',
   'досягти чогось, домогтися успіху',
   'She finally achieved her dream of becoming a doctor.',
   null, 'B2', 'book-import', true),

  ('family', 'Family', 'the source of something',
   'джерело чогось',
   'Her father was the main source of income for the family.',
   null, 'B2', 'book-import', true),

  ('family', 'Family', 'to take something for granted',
   'сприймати щось як належне',
   'He took his parents'' support for granted until he moved out on his own.',
   null, 'B2', 'book-import', true),

  ('family', 'Family', 'in the first flush of one''s maidenhood',
   'у розквіті молодості (про незаміжню дівчину)',
   'She was married off in the first flush of her maidenhood, before she turned twenty.',
   null, 'B2', 'book-import', true);
