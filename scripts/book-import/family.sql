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

-- Batch 3: "Man's Appearance and Character" + more idiom phrases (book pages 72-73,
-- book-source/..._page-0068.jpg and _page-0069.jpg). Adjectives for appearance, hair, eyes,
-- nose, and character/mood, plus hair-style phrases and family-structure idioms
-- ("a nuclear family", "an extended family", etc.). Translation and example below are
-- generated (not extracted), per skills/book-quiz-import/SKILL.md. transcription left null,
-- consistent with this topic's earlier batches.

insert into matkovska_quiz_bot.vocab_words
  (topic_id, topic_title, word, translation, example, transcription, level, source, active)
values
  ('family', 'Family', 'handsome', 'вродливий (про чоловіка)', 'Her older brother is tall and handsome, with dark hair and blue eyes.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'beautiful', 'вродлива, красива (про жінку)', 'Everyone said she was the most beautiful girl in the village.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'ugly', 'потворний, негарний', 'The old scarecrow in the field looked genuinely ugly.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'attractive', 'привабливий', 'He has an attractive smile that puts people at ease.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'broad-shouldered', 'широкоплечий', 'The rugby player was broad-shouldered and powerfully built.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'dark-eyed', 'темноокий', 'Their dark-eyed daughter takes after her Italian grandmother.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'dark-skinned', 'смуглявий, темношкірий', 'He came back from his holiday dark-skinned from the sun.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'long-sighted', 'далекозорий', 'My grandfather is long-sighted and needs glasses to read a newspaper up close.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'long-legged', 'довгоногий', 'The long-legged model walked confidently down the runway.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'long-armed', 'довгорукий', 'The long-armed goalkeeper easily reached the top corner of the goal.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'short-sighted', 'короткозорий', 'She''s short-sighted, so she wears glasses when she drives.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'good-looking', 'привабливий, гарний на вигляд', 'Her new boyfriend is tall and good-looking.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'plain', 'простий на вигляд, невиразний', 'She always said she felt plain next to her glamorous older sister.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'short', 'низький (на зріст)', 'He''s quite short, only about a metre sixty.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stout', 'огрядний, кремезний', 'The stout old innkeeper greeted every guest with a smile.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'slim', 'стрункий', 'She stayed slim by cycling to work every day.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'slender', 'тонкий, витончений', 'The dancer had long, slender legs.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'stooping', 'сутулий, зігнутий', 'The stooping old man leaned heavily on his walking stick.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'solidly-built', 'міцної статури', 'Their son grew into a solidly-built young man who played rugby for the university.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'tall', 'високий (на зріст)', 'My father is very tall - almost two metres.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'thin', 'худий, тонкий', 'He looked thin and tired after the long illness.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'curly', 'кучерявий', 'Her curly hair is exactly like her mother''s.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'fair', 'світле (волосся)', 'Their youngest daughter has fair hair and blue eyes.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'grey', 'сивий', 'His hair had turned completely grey by the age of fifty.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'straight', 'пряме (волосся)', 'She has long, straight hair that she never curls.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'bobbed', 'коротко підстрижене (каре)', 'She had her hair bobbed just below the ears for the summer.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'scanty', 'рідке (волосся)', 'His scanty grey hair barely covered the top of his head.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'wavy', 'хвилясте (волосся)', 'She has thick, wavy hair that she wears loose.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hair parted in the middle', 'волосся, розділене прямим проділом посередині', 'She wore her hair parted in the middle, just like in the old photograph.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hair combed back', 'зачесане назад волосся', 'He always keeps his hair combed back for work.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hair done in a knot', 'волосся, зібране у вузол', 'Her grandmother always had her hair done in a knot at the back of her head.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hair in plaits', 'волосся, заплетене в коси', 'The little girl went to school with her hair in plaits.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hair falls over the shoulders', 'волосся спадає на плечі', 'Her long hair falls over the shoulders whenever she takes off her hat.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hazel', 'карі, горіхового кольору (очі)', 'He has striking hazel eyes that seem to change colour in the light.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'close-set', 'близько посаджені (очі)', 'His close-set eyes gave his face a rather intense expression.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'deep-set', 'глибоко посаджені (очі)', 'Her deep-set eyes were the first thing people noticed about her.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hooked', 'гачкуватий (ніс)', 'The old sailor had a hooked nose and a weathered face.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'snub', 'кирпатий (ніс)', 'Their little boy has a snub nose covered in freckles.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'up-turned', 'кирпатий, із піднятим кінчиком (ніс)', 'She has an up-turned nose that makes her look permanently cheerful.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'aquiline', 'орлиний (ніс)', 'His aquiline nose gave his profile a rather noble look.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'generous', 'щедрий', 'My uncle is very generous - he always pays for everyone at dinner.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'reasonable', 'розсудливий, поміркований', 'Try to be reasonable; shouting at each other won''t solve anything.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'reserved', 'стриманий, замкнений', 'He''s quite reserved with strangers but very warm once you know him.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'frank', 'відвертий, щирий', 'I appreciate how frank she is - you always know where you stand with her.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'modest', 'скромний', 'Despite winning the award, he remained modest about his achievement.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'shy', 'сором''язливий', 'As a child she was too shy to speak in front of the class.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'timid', 'боязкий, полохливий', 'The timid new student barely said a word on his first day.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'reliable', 'надійний', 'You can always count on him; he''s the most reliable person I know.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'ambitious', 'амбітний, честолюбний', 'She''s ambitious and hopes to run her own company one day.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'pompous', 'пихатий, зарозумілий', 'Nobody liked the pompous manager who never listened to anyone else''s ideas.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'obstinate', 'впертий', 'He''s too obstinate to admit he was wrong.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'obedient', 'слухняний', 'Their dog is remarkably obedient - it never leaves her side.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'selfish', 'егоїстичний', 'It was selfish of him to take the last seat without asking.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'unselfish', 'безкорисливий, самовідданий', 'Her unselfish devotion to her family impressed everyone who knew her.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'self-confident', 'впевнений у собі', 'He walked into the interview looking calm and self-confident.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'gifted', 'обдарований, талановитий', 'Their daughter is a gifted pianist who started performing at the age of six.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'rude', 'грубий, нечемний', 'It was rude of him to interrupt her while she was speaking.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'naughty', 'неслухняний, пустотливий (про дитину)', 'The naughty twins hid their little sister''s shoes again.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'chivalrous', 'галантний, лицарський', 'He was always chivalrous, holding doors open and offering his seat.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'straightforward', 'прямий, відвертий у спілкуванні', 'I like dealing with him because he''s straightforward about what he wants.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'introverted', 'замкнений у собі, інтровертний', 'She''s quite introverted and prefers a quiet evening at home to a party.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'honest', 'чесний', 'Be honest with me - do you really like the present?', null, 'B2', 'book-import', true),
  ('family', 'Family', 'dishonest', 'нечесний', 'He lost his job after his dishonest dealings were discovered.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'vain', 'марнославний', 'He''s so vain that he checks his reflection in every shop window.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'energetic', 'енергійний', 'Their grandmother is remarkably energetic for her age.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'impulsive', 'імпульсивний', 'She''s impulsive and often makes decisions without thinking them through.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'even-tempered', 'врівноважений', 'He is an even-tempered man who rarely raises his voice.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'snobbish', 'снобістський, зверхній', 'Some of her snobbish relatives never approved of the marriage.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'hard-working', 'працьовитий', 'Their hard-working parents built the family business from nothing.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'irresponsible', 'безвідповідальний', 'It was irresponsible of him to leave the children alone.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'thrifty', 'ощадливий, економний', 'Her thrifty grandmother never wasted a single piece of bread.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'impudent', 'зухвалий, нахабний', 'The impudent boy answered his teacher back in front of the whole class.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'tactless', 'нетактовний', 'It was tactless of him to mention her divorce at the party.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'prudent', 'розсудливий, обачний', 'A prudent person saves some money for hard times.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'good-humoured', 'доброзичливий, у гарному гуморі', 'Their grandfather is a good-humoured old man who loves to tell jokes.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'two-faced', 'дволикий, лицемірний', 'She discovered her so-called friend was two-faced and had been gossiping about her.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'devoted', 'відданий', 'He''s a devoted father who never misses his children''s school events.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'caring', 'турботливий', 'She is a caring older sister who always looks after the younger ones.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'tired', 'втомлений', 'He looked tired after the long flight home.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'fresh', 'свіжий, бадьорий', 'She came back from her holiday looking fresh and rested.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'upset', 'засмучений, розстроєний', 'She was upset after hearing the bad news.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'disappointed', 'розчарований', 'He was disappointed when he didn''t get the job.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'sleepy', 'сонний', 'The children were too sleepy to finish their dinner.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'worried', 'стурбований', 'Her mother looked worried when she did not come home on time.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'miserable', 'нещасний, пригнічений', 'He felt miserable after failing his driving test twice.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'pale', 'блідий', 'She turned pale when she heard the news.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'unwell', 'нездоровий, погано почувається', 'He stayed home from school because he felt unwell.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'surprised', 'здивований', 'She was surprised to see her old friend at the wedding.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'as glum as a bear', 'похмурий як хмара, дуже похмурий', 'He''s been as glum as a bear ever since his team lost the match.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'a nuclear family', 'нуклеарна сім''я (лише батьки й діти)', 'A nuclear family - just husband, wife and their children - is the most common type of household in the city.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'an extended family', 'розширена сім''я (з бабусями, дідусями, тітками тощо)', 'In many villages, three generations of an extended family still live under one roof.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'a one-parent family', 'неповна сім''я (з одним із батьків)', 'She grew up in a one-parent family after her father left when she was five.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'to look alike', 'бути схожими один на одного', 'The twins look alike, but their personalities couldn''t be more different.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'a twinkle in your eye', 'вогник в очах, лукавий блиск в очах', 'Grandpa told the story with a twinkle in his eye, as if he still couldn''t believe it happened.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'to get along with someone', 'ладнати з кимось', 'She has always got along well with her younger brother.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'to follow in somebody''s footsteps', 'йти чиїмись слідами (обирати той самий шлях/професію)', 'He followed in his father''s footsteps and became a doctor too.', null, 'B2', 'book-import', true),
  ('family', 'Family', 'an elder brother', 'старший брат', 'My elder brother taught me to ride a bike. Note: ''elder'' is used this way only directly before a noun (an elder brother), never with ''than'' - you would say ''older than'' instead.', null, 'B2', 'book-import', true);

-- Grammar batch 1: three sets of ready-made multiple-choice material (book pages 73 and 76).
-- Set A (family-mc-1..22): occupation riddles from the "Occupation" word list (page 76, item 9).
-- Set B (family-mc-23..31): antonym pairs from the appearance-adjective matching exercise
-- (page 73, item 2). Set C (family-mc-32..36): odd-one-out groups (page 73, item 3).
-- explanation/grammar_rule are authored, not extracted - the book doesn't supply them for
-- this MC-riddle format, per skills/book-quiz-import/SKILL.md.

insert into matkovska_quiz_bot.grammar_questions
  (source_id, topic_id, topic_name, type, difficulty, sentence, options, correct_option_index, explanation, grammar_rule, level, source, active)
values
  ('family-mc-1', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone whose job is to design buildings.',
   array['architect', 'builder', 'engineer', 'plumber'], 0,
   'This riddle describes an architect. A builder, an engineer and a plumber are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-2', 'family', 'Family', 'multiple-choice', 'medium',
   'A person who builds or repairs buildings.',
   array['architect', 'plumber', 'mechanic', 'builder'], 3,
   'This riddle describes a builder. An architect, a plumber and a mechanic are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-3', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone whose job is to give beauty treatments to skin, hair, etc.',
   array['dentist', 'chemist', 'beautician', 'doctor'], 2,
   'This riddle describes a beautician. A doctor, a dentist and a chemist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-4', 'family', 'Family', 'multiple-choice', 'medium',
   'A professional performer, especially in music, dance, or the theatre.',
   array['composer', 'actor', 'actress', 'musician'], 1,
   'This riddle describes an actor. An actress, a musician and a composer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-5', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who produces art, especially paintings and drawings.',
   array['artist', 'composer', 'writer', 'sportsman'], 0,
   'This riddle describes an artist. A composer, a writer and a sportsman are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-6', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who writes books, stories, etc., especially as a job.',
   array['journalist', 'composer', 'artist', 'writer'], 3,
   'This riddle describes a writer. A journalist, a composer and an artist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-7', 'family', 'Family', 'multiple-choice', 'medium',
   'A secretary whose main job is to type letters.',
   array['librarian', 'journalist', 'typist', 'secretary'], 2,
   'This riddle describes a typist. A secretary, a librarian and a journalist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-8', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who is in charge of a local bank.',
   array['officer', 'banker', 'bank manager', 'lawyer'], 1,
   'This riddle describes a banker. A bank manager, a lawyer and an officer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-9', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone whose job is to teach.',
   array['teacher', 'librarian', 'lawyer', 'journalist'], 0,
   'This riddle describes a teacher. A librarian, a lawyer and a journalist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-10', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who works on a ship.',
   array['pilot', 'soldier', 'officer', 'sailor'], 3,
   'This riddle describes a sailor. A pilot, a soldier and an officer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-11', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who writes music.',
   array['artist', 'writer', 'composer', 'musician'], 2,
   'This riddle describes a composer. A musician, an artist and a writer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-12', 'family', 'Family', 'multiple-choice', 'medium',
   'A person who gives instructions to a computer to make it do a particular thing.',
   array['physicist', 'computer programmer', 'engineer', 'scientific worker'], 1,
   'This riddle describes a computer programmer. An engineer, a scientific worker and a physicist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-13', 'family', 'Family', 'multiple-choice', 'medium',
   'A member of the army, especially someone who is not an officer.',
   array['soldier', 'officer', 'sailor', 'police officer'], 0,
   'This riddle describes a soldier. An officer, a sailor and a police officer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-14', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone whose job is to treat people''s teeth.',
   array['doctor', 'surgeon', 'beautician', 'dentist'], 3,
   'This riddle describes a dentist. A doctor, a surgeon and a beautician are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-15', 'family', 'Family', 'multiple-choice', 'medium',
   'A doctor who does operations in hospital.',
   array['dentist', 'physicist', 'surgeon', 'doctor'], 2,
   'This riddle describes a surgeon. A doctor, a dentist and a physicist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-16', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who designs the way roads, bridges, machines, etc. are built.',
   array['scientific worker', 'engineer', 'architect', 'mechanic'], 1,
   'This riddle describes an engineer. An architect, a mechanic and a scientific worker are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-17', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone whose job is to advise people about laws, write formal agreements, or represent people in court.',
   array['lawyer', 'officer', 'banker', 'journalist'], 0,
   'This riddle describes a lawyer. An officer, a banker and a journalist are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-18', 'family', 'Family', 'multiple-choice', 'medium',
   'A person who plays a musical instrument, especially very well or as a job.',
   array['composer', 'artist', 'actor', 'musician'], 3,
   'This riddle describes a musician. A composer, an artist and an actor are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-19', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone skilled at repairing motor vehicles and machinery.',
   array['builder', 'plumber', 'mechanic', 'engineer'], 2,
   'This riddle describes a mechanic. An engineer, a builder and a plumber are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-20', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone who operates the controls of an aircraft or spacecraft.',
   array['sailor', 'pilot', 'driver', 'taxi driver'], 1,
   'This riddle describes a pilot. A driver, a taxi driver and a sailor are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-21', 'family', 'Family', 'multiple-choice', 'medium',
   'A person whose job is to make sure people obey the law, catch criminals, and protect people and property.',
   array['police officer', 'officer', 'soldier', 'lawyer'], 0,
   'This riddle describes a police officer. An officer, a soldier and a lawyer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-22', 'family', 'Family', 'multiple-choice', 'medium',
   'Someone whose job is to repair waterpipes, baths, sinks, etc.',
   array['builder', 'mechanic', 'engineer', 'plumber'], 3,
   'This riddle describes a plumber. A builder, a mechanic and an engineer are related occupations but do not match this specific job description.',
   'Occupation vocabulary — identifying a job from its definition.', 'B2', 'book-import', true),

  ('family-mc-23', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''handsome''?',
   array['plain', 'ugly', 'stout', 'short'], 1,
   'The opposite of ''handsome'' is ''ugly''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-24', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''tall''?',
   array['stout', 'short', 'plain', 'fair'], 1,
   'The opposite of ''tall'' is ''short''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-25', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''attractive''?',
   array['ugly', 'plain', 'snub', 'stout'], 1,
   'The opposite of ''attractive'' is ''plain''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-26', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''dark''?',
   array['short', 'fair', 'healthy', 'easy'], 1,
   'The opposite of ''dark'' is ''fair''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-27', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''straight''?',
   array['plain', 'snub', 'stout', 'ugly'], 1,
   'The opposite of ''straight'' is ''snub''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-28', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''long''?',
   array['easy', 'short', 'healthy', 'fair'], 1,
   'The opposite of ''long'' is ''short''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-29', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''ill''?',
   array['stout', 'healthy', 'easy', 'plain'], 1,
   'The opposite of ''ill'' is ''healthy''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-30', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''thin''?',
   array['fair', 'stout', 'snub', 'ugly'], 1,
   'The opposite of ''thin'' is ''stout''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-31', 'family', 'Family', 'multiple-choice', 'medium',
   'What is the opposite of ''hard''?',
   array['healthy', 'easy', 'plain', 'short'], 1,
   'The opposite of ''hard'' is ''easy''.',
   'Antonyms — adjectives describing appearance and physical condition.', 'B2', 'book-import', true),

  ('family-mc-32', 'family', 'Family', 'multiple-choice', 'medium',
   'Which word does not belong in this group: Father, Daughter, Husband, Mother, Son, Brother?',
   array['Father', 'Daughter', 'Husband', 'Mother', 'Son', 'Brother'], 2,
   '''Husband'' is the odd one out because it is a relation by marriage; ''father'', ''daughter'', ''mother'', ''son'' and ''brother'' are all blood relations.',
   'Odd one out — grouping by meaning and part of speech.', 'B2', 'book-import', true),

  ('family-mc-33', 'family', 'Family', 'multiple-choice', 'medium',
   'Which word does not belong in this group: Teacher, Doctor, Clown, Teenager, Translator, Shop assistant?',
   array['Teacher', 'Doctor', 'Clown', 'Teenager', 'Translator', 'Shop assistant'], 3,
   '''Teenager'' is the odd one out because it describes a person''s age, not their occupation; all the other words name jobs.',
   'Odd one out — grouping by meaning and part of speech.', 'B2', 'book-import', true),

  ('family-mc-34', 'family', 'Family', 'multiple-choice', 'medium',
   'Which word does not belong in this group: Handsome, Nice, Ugly, Good-looking, Attractive, Beautiful?',
   array['Handsome', 'Nice', 'Ugly', 'Good-looking', 'Attractive', 'Beautiful'], 2,
   '''Ugly'' is the odd one out because it is a negative appearance word; the rest all describe good looks.',
   'Odd one out — grouping by meaning and part of speech.', 'B2', 'book-import', true),

  ('family-mc-35', 'family', 'Family', 'multiple-choice', 'medium',
   'Which word does not belong in this group: Kind, Obedient, Frank, Rude, Generous, Shy?',
   array['Kind', 'Obedient', 'Frank', 'Rude', 'Generous', 'Shy'], 3,
   '''Rude'' is the odd one out because it is a negative character trait; the rest describe positive or neutral qualities.',
   'Odd one out — grouping by meaning and part of speech.', 'B2', 'book-import', true),

  ('family-mc-36', 'family', 'Family', 'multiple-choice', 'medium',
   'Which word does not belong in this group: Old, Young, Middle-aged, Elderly, Youth?',
   array['Old', 'Young', 'Middle-aged', 'Elderly', 'Youth'], 4,
   '''Youth'' is the odd one out because it is a noun, not an adjective like the other four words.',
   'Odd one out — grouping by meaning and part of speech.', 'B2', 'book-import', true);
