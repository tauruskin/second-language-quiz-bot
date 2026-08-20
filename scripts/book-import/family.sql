-- Book import: Main Course Unit 1 ("Family" - confirmed by the "ESSENTIAL VOCABULARY" box on
-- printed page 71, file page-0067.jpg, which is titled FAMILY at its center node).
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

-- Batch 2: "ESSENTIAL VOCABULARY / FAMILY" box, Relationship > By Birth and By Marriage
-- (book-source/..._page-0067.jpg, printed page 71) + "CULTURE CONTEXT" definitions
-- (book-source/..._page-0076.jpg, printed page 80). In-law terms are expanded from the book's
-- parenthetical shorthand (e.g. "brother (sister)-in-law" -> two separate rows) and given
-- composite Ukrainian translations since English collapses distinctions Ukrainian makes by
-- gender/side-of-family - flagged for review, not a simple 1:1 gloss.

insert into matkovska_quiz_bot.vocab_words
  (topic_id, topic_title, word, translation, example, transcription, level, source, active)
values
  ('family', 'Family', 'aunt', 'тітка', 'My aunt visits us every Christmas.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'brother', 'брат', 'My younger brother is still at school.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'cousin', 'двоюрідний брат / двоюрідна сестра', 'My cousin lives in Kyiv.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'children', 'діти', 'They have three children.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'daughter', 'дочка', 'Their daughter just started university.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'father', 'батько', 'My father works as an engineer.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'grandmother', 'бабуся', 'My grandmother bakes the best bread.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'grandfather', 'дідусь', 'My grandfather tells wonderful stories.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'grandparents', 'бабуся й дідусь', 'We visit our grandparents every summer.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'great-grandmother', 'прабабуся', 'My great-grandmother lived to be ninety-eight.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'great-grandfather', 'прадідусь', 'I never met my great-grandfather.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'nephew', 'племінник', 'My nephew just started school.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'niece', 'племінниця', 'I bought my niece a birthday present.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'mother', 'мати', 'My mother is a teacher.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'parents', 'батьки', 'My parents live in Lviv.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'uncle', 'дядько', 'My uncle taught me how to fish.', null, 'B2', 'book-import', true),

  ('family', 'Family', 'brother-in-law', 'зять/шурин (брат чоловіка або дружини)', 'My brother-in-law helped us move house.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'sister-in-law', 'невістка/зовиця (сестра чоловіка або дружини)', 'My sister-in-law is coming for dinner tonight.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'father-in-law', 'тесть (батько дружини) / свекор (батько чоловіка)', 'My father-in-law is a retired doctor.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'mother-in-law', 'теща (мати дружини) / свекруха (мати чоловіка)', 'My mother-in-law makes wonderful borscht.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'fiance', 'наречений', 'She introduced her fiance to the family.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'fiancee', 'наречена', 'He proposed to his fiancee last spring.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'husband', 'чоловік', 'Her husband works abroad.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepmother', 'мачуха', 'His stepmother raised him from the age of five.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepfather', 'вітчим', 'Her stepfather is very kind to her.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepchildren', 'пасинки й падчерки', 'They have two stepchildren from his first marriage.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepsister', 'зведена сестра', 'My stepsister and I get along really well.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepbrother', 'зведений брат', 'My stepbrother is two years older than me.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepson', 'пасинок', 'He treats his stepson like his own child.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stepdaughter', 'падчерка', 'She loves her stepdaughter as if she were her own.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'wife', 'дружина', 'His wife works as a lawyer.', null, 'B2', 'book-import', true),

  ('family', 'Family', 'a comprehensive school', 'загальноосвітня школа (Великобританія)', 'In Britain, a comprehensive school teaches pupils of all abilities from the age of eleven.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'a freelance translator', 'перекладач-фрилансер', 'She works as a freelance translator, taking on projects for different clients.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'a boarding school', 'школа-інтернат', 'Judy attends a boarding school far from her parents'' home.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'a senior citizen', 'особа похилого віку, пенсіонер', 'As a senior citizen, he receives a discount on public transport.', null, 'B2', 'book-import', true);
