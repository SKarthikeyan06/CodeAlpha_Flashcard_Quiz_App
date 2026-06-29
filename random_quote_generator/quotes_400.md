# 400 Professional Quotes — Random Quote Generator

## Usage in Flutter

Each quote maps to one row in the `quotes` SQLite table.
Copy the `_seedData` list into `database_helper.dart`.

---

## Dart seed data — paste into database_helper.dart

```dart
static const List<Map<String, dynamic>> _seedData = [

  // ─────────────────────────────────────────
  // EDUCATION (quotes 1–60)
  // ─────────────────────────────────────────

  {'text': 'Education is the most powerful weapon which you can use to change the world.', 'author': 'Nelson Mandela', 'category': 'Education'},
  {'text': 'The roots of education are bitter, but the fruit is sweet.', 'author': 'Aristotle', 'category': 'Education'},
  {'text': 'Live as if you were to die tomorrow. Learn as if you were to live forever.', 'author': 'Mahatma Gandhi', 'category': 'Education'},
  {'text': 'An investment in knowledge pays the best interest.', 'author': 'Benjamin Franklin', 'category': 'Education'},
  {'text': 'The beautiful thing about learning is that no one can take it away from you.', 'author': 'B.B. King', 'category': 'Education'},
  {'text': 'Education is not preparation for life; education is life itself.', 'author': 'John Dewey', 'category': 'Education'},
  {'text': 'The more that you read, the more things you will know.', 'author': 'Dr. Seuss', 'category': 'Education'},
  {'text': 'Intelligence plus character — that is the goal of true education.', 'author': 'Martin Luther King Jr.', 'category': 'Education'},
  {'text': 'The function of education is to teach one to think intensively and critically.', 'author': 'Martin Luther King Jr.', 'category': 'Education'},
  {'text': 'Education is the passport to the future, for tomorrow belongs to those who prepare for it today.', 'author': 'Malcolm X', 'category': 'Education'},
  {'text': 'It is the mark of an educated mind to be able to entertain a thought without accepting it.', 'author': 'Aristotle', 'category': 'Education'},
  {'text': 'The mind is not a vessel to be filled, but a fire to be kindled.', 'author': 'Plutarch', 'category': 'Education'},
  {'text': 'Wisdom is not a product of schooling but of the lifelong attempt to acquire it.', 'author': 'Albert Einstein', 'category': 'Education'},
  {'text': 'Education is the kindling of a flame, not the filling of a vessel.', 'author': 'Socrates', 'category': 'Education'},
  {'text': 'The aim of education is the knowledge not of facts but of values.', 'author': 'William Inge', 'category': 'Education'},
  {'text': 'You learn something every day if you pay attention.', 'author': 'Ray LeBlond', 'category': 'Education'},
  {'text': 'Develop a passion for learning. If you do, you will never cease to grow.', 'author': 'Anthony J. D\'Angelo', 'category': 'Education'},
  {'text': 'The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice.', 'author': 'Brian Herbert', 'category': 'Education'},
  {'text': 'Learning is not attained by chance; it must be sought for with ardor and attended to with diligence.', 'author': 'Abigail Adams', 'category': 'Education'},
  {'text': 'Tell me and I forget. Teach me and I remember. Involve me and I learn.', 'author': 'Benjamin Franklin', 'category': 'Education'},
  {'text': 'The only person who is educated is the one who has learned how to learn and change.', 'author': 'Carl Rogers', 'category': 'Education'},
  {'text': 'A good teacher can inspire hope, ignite the imagination, and instill a love of learning.', 'author': 'Brad Henry', 'category': 'Education'},
  {'text': 'Education is not the filling of a pail, but the lighting of a fire.', 'author': 'William Butler Yeats', 'category': 'Education'},
  {'text': 'Knowledge is power. Information is liberating. Education is the premise of progress.', 'author': 'Kofi Annan', 'category': 'Education'},
  {'text': 'The secret of getting ahead is getting started.', 'author': 'Mark Twain', 'category': 'Education'},
  {'text': 'It always seems impossible until it is done.', 'author': 'Nelson Mandela', 'category': 'Education'},
  {'text': 'The expert in anything was once a beginner.', 'author': 'Helen Hayes', 'category': 'Education'},
  {'text': 'One child, one teacher, one book, and one pen can change the world.', 'author': 'Malala Yousafzai', 'category': 'Education'},
  {'text': 'Education is the movement from darkness to light.', 'author': 'Allan Bloom', 'category': 'Education'},
  {'text': 'The goal of education is not to increase the amount of knowledge but to create the possibilities for a child to invent and discover.', 'author': 'Jean Piaget', 'category': 'Education'},
  {'text': 'Without education, you are not going anywhere in this world.', 'author': 'Malcolm X', 'category': 'Education'},
  {'text': 'Curiosity is the wick in the candle of learning.', 'author': 'William Arthur Ward', 'category': 'Education'},
  {'text': 'The whole purpose of education is to turn mirrors into windows.', 'author': 'Sydney J. Harris', 'category': 'Education'},
  {'text': 'A mind that is stretched by a new experience can never go back to its old dimensions.', 'author': 'Oliver Wendell Holmes', 'category': 'Education'},
  {'text': 'The more I learn, the more I realize how much I do not know.', 'author': 'Albert Einstein', 'category': 'Education'},
  {'text': 'Real learning comes about when the competitive spirit has ceased.', 'author': 'Jiddu Krishnamurti', 'category': 'Education'},
  {'text': 'To teach is to learn twice.', 'author': 'Joseph Joubert', 'category': 'Education'},
  {'text': 'Books are the quietest and most constant of friends; they are the most accessible and wisest of counselors.', 'author': 'Charles W. Eliot', 'category': 'Education'},
  {'text': 'Education is what remains after one has forgotten what one has learned in school.', 'author': 'Albert Einstein', 'category': 'Education'},
  {'text': 'The illiterate of the 21st century will not be those who cannot read and write, but those who cannot learn, unlearn, and relearn.', 'author': 'Alvin Toffler', 'category': 'Education'},
  {'text': 'Change is the end result of all true learning.', 'author': 'Leo Buscaglia', 'category': 'Education'},
  {'text': 'The mediocre teacher tells. The good teacher explains. The superior teacher demonstrates. The great teacher inspires.', 'author': 'William Arthur Ward', 'category': 'Education'},
  {'text': 'Education is the ability to listen to almost anything without losing your temper or your self-confidence.', 'author': 'Robert Frost', 'category': 'Education'},
  {'text': 'You can never be overdressed or overeducated.', 'author': 'Oscar Wilde', 'category': 'Education'},
  {'text': 'The pen is mightier than the sword.', 'author': 'Edward Bulwer-Lytton', 'category': 'Education'},
  {'text': 'In learning you will teach, and in teaching you will learn.', 'author': 'Phil Collins', 'category': 'Education'},
  {'text': 'The highest result of education is tolerance.', 'author': 'Helen Keller', 'category': 'Education'},
  {'text': 'Education is what survives when what has been learned has been forgotten.', 'author': 'B.F. Skinner', 'category': 'Education'},
  {'text': 'The purpose of education is to replace an empty mind with an open one.', 'author': 'Malcolm Forbes', 'category': 'Education'},
  {'text': 'Knowledge is the eye of desire and can become the pilot of the soul.', 'author': 'Will Durant', 'category': 'Education'},
  {'text': 'A reader lives a thousand lives before he dies. The man who never reads lives only one.', 'author': 'George R.R. Martin', 'category': 'Education'},
  {'text': 'The only true wisdom is in knowing you know nothing.', 'author': 'Socrates', 'category': 'Education'},
  {'text': 'Education breeds confidence. Confidence breeds hope. Hope breeds peace.', 'author': 'Confucius', 'category': 'Education'},
  {'text': 'Study without desire spoils the memory, and it retains nothing that it takes in.', 'author': 'Leonardo da Vinci', 'category': 'Education'},
  {'text': 'The foundation of every state is the education of its youth.', 'author': 'Diogenes', 'category': 'Education'},
  {'text': 'Learning never exhausts the mind.', 'author': 'Leonardo da Vinci', 'category': 'Education'},
  {'text': 'What we learn with pleasure we never forget.', 'author': 'Alfred Mercier', 'category': 'Education'},
  {'text': 'Anyone who stops learning is old, whether at twenty or eighty.', 'author': 'Henry Ford', 'category': 'Education'},
  {'text': 'The art of teaching is the art of assisting discovery.', 'author': 'Mark Van Doren', 'category': 'Education'},
  {'text': 'Education is not just about going to school and getting a degree. It is about widening your knowledge and absorbing the truth about life.', 'author': 'Shakuntala Devi', 'category': 'Education'},

  // ─────────────────────────────────────────
  // SPORTS (quotes 61–130)
  // ─────────────────────────────────────────

  {'text': 'Champions keep playing until they get it right.', 'author': 'Billie Jean King', 'category': 'Sports'},
  {'text': 'The more difficult the victory, the greater the happiness in winning.', 'author': 'Pelé', 'category': 'Sports'},
  {'text': 'You miss 100% of the shots you do not take.', 'author': 'Wayne Gretzky', 'category': 'Sports'},
  {'text': 'It is not the size of a man but the size of his heart that matters.', 'author': 'Evander Holyfield', 'category': 'Sports'},
  {'text': 'The only way to prove that you are a good sport is to lose.', 'author': 'Ernie Banks', 'category': 'Sports'},
  {'text': 'Hard work beats talent when talent does not work hard.', 'author': 'Tim Notke', 'category': 'Sports'},
  {'text': 'Do not let what you cannot do interfere with what you can do.', 'author': 'John Wooden', 'category': 'Sports'},
  {'text': 'Winning is not everything, but wanting to win is.', 'author': 'Vince Lombardi', 'category': 'Sports'},
  {'text': 'It is not whether you get knocked down, it is whether you get up.', 'author': 'Vince Lombardi', 'category': 'Sports'},
  {'text': 'Success is where preparation and opportunity meet.', 'author': 'Bobby Unser', 'category': 'Sports'},
  {'text': 'The difference between the impossible and the possible lies in determination.', 'author': 'Tommy Lasorda', 'category': 'Sports'},
  {'text': 'You have to expect things of yourself before you can do them.', 'author': 'Michael Jordan', 'category': 'Sports'},
  {'text': 'Obstacles do not have to stop you. If you run into a wall, do not turn around and give up.', 'author': 'Michael Jordan', 'category': 'Sports'},
  {'text': 'I can accept failure, everyone fails at something. But I cannot accept not trying.', 'author': 'Michael Jordan', 'category': 'Sports'},
  {'text': 'The mind is the limit. As long as the mind can envision the fact that you can do something, you can do it.', 'author': 'Arnold Schwarzenegger', 'category': 'Sports'},
  {'text': 'Pain is temporary. Quitting lasts forever.', 'author': 'Lance Armstrong', 'category': 'Sports'},
  {'text': 'Show me a gracious loser and I will show you a failure.', 'author': 'Knute Rockne', 'category': 'Sports'},
  {'text': 'Most people give up just when they are about to achieve success.', 'author': 'Ross Perot', 'category': 'Sports'},
  {'text': 'A champion is someone who gets up when he cannot.', 'author': 'Jack Dempsey', 'category': 'Sports'},
  {'text': 'Float like a butterfly, sting like a bee.', 'author': 'Muhammad Ali', 'category': 'Sports'},
  {'text': 'I hated every minute of training, but I said, do not quit. Suffer now and live the rest of your life as a champion.', 'author': 'Muhammad Ali', 'category': 'Sports'},
  {'text': 'Impossible is just a big word thrown around by small men who find it easier to live in the world they have been given than to explore the power they have to change it.', 'author': 'Muhammad Ali', 'category': 'Sports'},
  {'text': 'The more I practice, the luckier I get.', 'author': 'Gary Player', 'category': 'Sports'},
  {'text': 'Sweat is the cologne of accomplishment.', 'author': 'Heywood Hale Broun', 'category': 'Sports'},
  {'text': 'Gold medals are not really made of gold. They are made of sweat, determination, and a hard-to-find alloy called guts.', 'author': 'Dan Gable', 'category': 'Sports'},
  {'text': 'Never give up, never give in, and when the upper hand is ours, may we have the wisdom to be magnanimous.', 'author': 'Hubert H. Humphrey', 'category': 'Sports'},
  {'text': 'One man practicing sportsmanship is far better than a hundred teaching it.', 'author': 'Knute Rockne', 'category': 'Sports'},
  {'text': 'Sports teach you character, it teaches you to play by the rules, it teaches you to know what it feels like to win and lose.', 'author': 'Billie Jean King', 'category': 'Sports'},
  {'text': 'To uncover your true potential you must first find your own limits and then you have to have the courage to blow past them.', 'author': 'Picabo Street', 'category': 'Sports'},
  {'text': 'You were not born a winner, and you were not born a loser. You are what you make yourself be.', 'author': 'Lou Holtz', 'category': 'Sports'},
  {'text': 'The secret of winning football games is working more as a team, less as individuals.', 'author': 'Knute Rockne', 'category': 'Sports'},
  {'text': 'Talent wins games, but teamwork and intelligence wins championships.', 'author': 'Michael Jordan', 'category': 'Sports'},
  {'text': 'You cannot put a limit on anything. The more you dream, the farther you get.', 'author': 'Michael Phelps', 'category': 'Sports'},
  {'text': 'If you fail to prepare, you are prepared to fail.', 'author': 'Mark Spitz', 'category': 'Sports'},
  {'text': 'Set your goals high, and do not stop till you get there.', 'author': 'Bo Jackson', 'category': 'Sports'},
  {'text': 'The game has its ups and downs, but you can never lose focus of your individual goals.', 'author': 'Michael Jordan', 'category': 'Sports'},
  {'text': 'It is not the will to win that matters — everyone has that. It is the will to prepare to win that matters.', 'author': 'Paul Bryant', 'category': 'Sports'},
  {'text': 'I always felt that my greatest asset was not my physical ability, it was my mental ability.', 'author': 'Bruce Jenner', 'category': 'Sports'},
  {'text': 'Leadership, like coaching, is fighting for the hearts and souls of men.', 'author': 'Pat Riley', 'category': 'Sports'},
  {'text': 'Serious sport has nothing to do with fair play. It is bound up with hatred, jealousy, boastfulness, disregard of all rules, and sadistic pleasure in witnessing violence.', 'author': 'George Orwell', 'category': 'Sports'},
  {'text': 'You cannot win unless you learn how to lose.', 'author': 'Kareem Abdul-Jabbar', 'category': 'Sports'},
  {'text': 'Never let the fear of striking out keep you from playing the game.', 'author': 'Babe Ruth', 'category': 'Sports'},
  {'text': 'Excellence is the gradual result of always striving to do better.', 'author': 'Pat Riley', 'category': 'Sports'},
  {'text': 'The key is not the will to win. Everybody has that. It is the will to prepare to win.', 'author': 'Bobby Knight', 'category': 'Sports'},
  {'text': 'Number one is just to gain a passion for running. To love the morning, to love the trail, to love the pace on the track.', 'author': 'Pat Tyson', 'category': 'Sports'},
  {'text': 'The five S\'s of sports training are: stamina, speed, strength, skill, and spirit; but the greatest of these is spirit.', 'author': 'Ken Doherty', 'category': 'Sports'},
  {'text': 'An athlete cannot run with money in his pockets. He must run with hope in his heart.', 'author': 'Emil Zatopek', 'category': 'Sports'},
  {'text': 'Champions are not born. They are made from something deep inside them — a desire, a dream, a vision.', 'author': 'Vince Lombardi', 'category': 'Sports'},
  {'text': 'The principle is competing against yourself. It is about self-improvement, about being better than you were the day before.', 'author': 'Steve Young', 'category': 'Sports'},
  {'text': 'I am building a fire, and every day I train, I add more fuel. At just the right moment, I light the match.', 'author': 'Mia Hamm', 'category': 'Sports'},
  {'text': 'What makes something special is not just what you have to gain, but what you feel there is to lose.', 'author': 'Andre Agassi', 'category': 'Sports'},
  {'text': 'Every champion was once a contender who refused to give up.', 'author': 'Rocky Balboa', 'category': 'Sports'},
  {'text': 'The will to win is important, but the will to prepare is vital.', 'author': 'Joe Paterno', 'category': 'Sports'},
  {'text': 'Good, better, best. Never let it rest until your good is better and your better is best.', 'author': 'Tim Duncan', 'category': 'Sports'},
  {'text': 'Age is no barrier. It is a limitation you put on your mind.', 'author': 'Jackie Joyner-Kersee', 'category': 'Sports'},
  {'text': 'You have to train your mind like you train your body.', 'author': 'Bruce Jenner', 'category': 'Sports'},
  {'text': 'I want to be remembered as the one who tried.', 'author': 'Shaquille O\'Neal', 'category': 'Sports'},
  {'text': 'Continuous effort — not strength or intelligence — is the key to unlocking our potential.', 'author': 'Winston Churchill', 'category': 'Sports'},
  {'text': 'You are never really playing an opponent. You are playing yourself.', 'author': 'Arthur Ashe', 'category': 'Sports'},
  {'text': 'A trophy carries dust. Memories last forever.', 'author': 'Mary Lou Retton', 'category': 'Sports'},
  {'text': 'It is hard to beat a person who never gives up.', 'author': 'Babe Ruth', 'category': 'Sports'},

  // ─────────────────────────────────────────
  // ENTERTAINMENT (quotes 131–200)
  // ─────────────────────────────────────────

  {'text': 'The stuff that dreams are made of.', 'author': 'Humphrey Bogart', 'category': 'Entertainment'},
  {'text': 'All the world is a stage, and all the men and women merely players.', 'author': 'William Shakespeare', 'category': 'Entertainment'},
  {'text': 'Art enables us to find ourselves and lose ourselves at the same time.', 'author': 'Thomas Merton', 'category': 'Entertainment'},
  {'text': 'Music gives a soul to the universe, wings to the mind, flight to the imagination, and life to everything.', 'author': 'Plato', 'category': 'Entertainment'},
  {'text': 'Without music, life would be a mistake.', 'author': 'Friedrich Nietzsche', 'category': 'Entertainment'},
  {'text': 'The purpose of art is washing the dust of daily life off our souls.', 'author': 'Pablo Picasso', 'category': 'Entertainment'},
  {'text': 'Entertainment is not escapism. It is a way of exploring the human condition.', 'author': 'Stephen King', 'category': 'Entertainment'},
  {'text': 'Creativity takes courage.', 'author': 'Henri Matisse', 'category': 'Entertainment'},
  {'text': 'I would rather entertain and hope that people learned something than educate people and hope that they were entertained.', 'author': 'Walt Disney', 'category': 'Entertainment'},
  {'text': 'The show must go on.', 'author': 'Traditional Theatre Saying', 'category': 'Entertainment'},
  {'text': 'Acting is not about being someone different. It is finding the similarity in what is apparently different, then finding myself in there.', 'author': 'Meryl Streep', 'category': 'Entertainment'},
  {'text': 'The job of the artist is always to deepen the mystery.', 'author': 'Francis Bacon', 'category': 'Entertainment'},
  {'text': 'In music, the silence between notes is as important as the notes themselves.', 'author': 'Debussy', 'category': 'Entertainment'},
  {'text': 'Laughter is the closest thing to the grace of God.', 'author': 'Karl Barth', 'category': 'Entertainment'},
  {'text': 'Music can change the world because it can change people.', 'author': 'Bono', 'category': 'Entertainment'},
  {'text': 'Art is not what you see, but what you make others see.', 'author': 'Edgar Degas', 'category': 'Entertainment'},
  {'text': 'The greatest art is to shape the quality of the day.', 'author': 'Henry David Thoreau', 'category': 'Entertainment'},
  {'text': 'Cinema is a matter of what is in the frame and what is out.', 'author': 'Martin Scorsese', 'category': 'Entertainment'},
  {'text': 'Every artist dips his brush in his own soul and paints his own nature into his pictures.', 'author': 'Henry Ward Beecher', 'category': 'Entertainment'},
  {'text': 'Life is a song — sing it. Life is a game — play it. Life is a challenge — meet it.', 'author': 'Sai Baba', 'category': 'Entertainment'},
  {'text': 'Great art picks up where nature ends.', 'author': 'Marc Chagall', 'category': 'Entertainment'},
  {'text': 'I never made one of my discoveries through the process of rational thinking.', 'author': 'Albert Einstein', 'category': 'Entertainment'},
  {'text': 'Imagination is more important than knowledge.', 'author': 'Albert Einstein', 'category': 'Entertainment'},
  {'text': 'Film is one of the three universal languages, the other two: mathematics and music.', 'author': 'Frank Capra', 'category': 'Entertainment'},
  {'text': 'The dance is the mother of the arts.', 'author': 'Curt Sachs', 'category': 'Entertainment'},
  {'text': 'Comedy is simply a funny way of being serious.', 'author': 'Peter Ustinov', 'category': 'Entertainment'},
  {'text': 'I think cinema, movies, and magic have always been closely associated.', 'author': 'Francis Ford Coppola', 'category': 'Entertainment'},
  {'text': 'Television is a medium of entertainment which permits millions of people to listen to the same joke at the same time.', 'author': 'T.S. Eliot', 'category': 'Entertainment'},
  {'text': 'Drama is life with the dull bits cut out.', 'author': 'Alfred Hitchcock', 'category': 'Entertainment'},
  {'text': 'We are all storytellers. We all live in a network of stories.', 'author': 'Antonio Machado', 'category': 'Entertainment'},
  {'text': 'The role of art is not to reproduce the visible but to make visible.', 'author': 'Paul Klee', 'category': 'Entertainment'},
  {'text': 'If it is not fun, you are not doing it right.', 'author': 'Bob Basso', 'category': 'Entertainment'},
  {'text': 'Entertainment is everyone\'s need. A good film can make a bad day a good memory.', 'author': 'Roger Ebert', 'category': 'Entertainment'},
  {'text': 'One good thing about music — when it hits you, you feel no pain.', 'author': 'Bob Marley', 'category': 'Entertainment'},
  {'text': 'If I cannot dance, I want no part in your revolution.', 'author': 'Emma Goldman', 'category': 'Entertainment'},
  {'text': 'Where words fail, music speaks.', 'author': 'Hans Christian Andersen', 'category': 'Entertainment'},
  {'text': 'Laughter is the sun that drives winter from the human face.', 'author': 'Victor Hugo', 'category': 'Entertainment'},
  {'text': 'I like nonsense; it wakes up the brain cells.', 'author': 'Dr. Seuss', 'category': 'Entertainment'},
  {'text': 'Stories are the creative conversion of life itself into a more powerful, clearer, more meaningful experience.', 'author': 'Robert McKee', 'category': 'Entertainment'},
  {'text': 'The universe is made of stories, not of atoms.', 'author': 'Muriel Rukeyser', 'category': 'Entertainment'},
  {'text': 'A film is never really good unless the camera is an eye in the head of a poet.', 'author': 'Orson Welles', 'category': 'Entertainment'},
  {'text': 'Theater is not an escape from reality; it is a way of engaging with it.', 'author': 'Wole Soyinka', 'category': 'Entertainment'},
  {'text': 'Great art is as irrational as great music. It is strange that both men and women would rather face the terror of art than the ennui of order.', 'author': 'George Jean Nathan', 'category': 'Entertainment'},
  {'text': 'The first duty of comedy is to make people laugh.', 'author': 'Mel Brooks', 'category': 'Entertainment'},
  {'text': 'Painting is poetry that is seen rather than felt, and poetry is painting that is felt rather than seen.', 'author': 'Leonardo da Vinci', 'category': 'Entertainment'},
  {'text': 'An actor is at his best a kind of unfrocked priest.', 'author': 'Alexander Knox', 'category': 'Entertainment'},
  {'text': 'I would rather have people laugh at my films than at me.', 'author': 'Buster Keaton', 'category': 'Entertainment'},
  {'text': 'Music is the shorthand of emotion.', 'author': 'Leo Tolstoy', 'category': 'Entertainment'},
  {'text': 'Every piece of music is a portrait of what is possible.', 'author': 'Joep Beving', 'category': 'Entertainment'},
  {'text': 'Good fiction creates empathy. A novel takes you somewhere and asks you to look through the eyes of another person.', 'author': 'Barbara Kingsolver', 'category': 'Entertainment'},
  {'text': 'The world is a tragedy to those who feel, but a comedy to those who think.', 'author': 'Horace Walpole', 'category': 'Entertainment'},
  {'text': 'The best stories don\'t come from good vs. bad but good vs. good.', 'author': 'Leo Tolstoy', 'category': 'Entertainment'},
  {'text': 'Art is the lie that enables us to realize the truth.', 'author': 'Pablo Picasso', 'category': 'Entertainment'},
  {'text': 'You do not have to be great to start, but you have to start to be great.', 'author': 'Zig Ziglar', 'category': 'Entertainment'},
  {'text': 'Creativity is intelligence having fun.', 'author': 'Albert Einstein', 'category': 'Entertainment'},
  {'text': 'The human race has only one really effective weapon and that is laughter.', 'author': 'Mark Twain', 'category': 'Entertainment'},
  {'text': 'If you want a happy ending, that depends, of course, on where you stop your story.', 'author': 'Orson Welles', 'category': 'Entertainment'},
  {'text': 'To send light into the darkness of men\'s hearts — such is the duty of the artist.', 'author': 'Robert Schumann', 'category': 'Entertainment'},
  {'text': 'The role of a writer is not to say what we all can say, but what we are unable to say.', 'author': 'Anaïs Nin', 'category': 'Entertainment'},
  {'text': 'Entertainment without values is the surest road to public depravity.', 'author': 'T.S. Eliot', 'category': 'Entertainment'},
  {'text': 'We are what we pretend to be, so we must be careful about what we pretend to be.', 'author': 'Kurt Vonnegut', 'category': 'Entertainment'},
  {'text': 'Films can be a mirror held up to social reality.', 'author': 'Spike Lee', 'category': 'Entertainment'},

  // ─────────────────────────────────────────
  // MOTIVATION (quotes 201–260)
  // ─────────────────────────────────────────

  {'text': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs', 'category': 'Motivation'},
  {'text': 'Believe you can and you are halfway there.', 'author': 'Theodore Roosevelt', 'category': 'Motivation'},
  {'text': 'The future belongs to those who believe in the beauty of their dreams.', 'author': 'Eleanor Roosevelt', 'category': 'Motivation'},
  {'text': 'In the middle of every difficulty lies opportunity.', 'author': 'Albert Einstein', 'category': 'Motivation'},
  {'text': 'It does not matter how slowly you go as long as you do not stop.', 'author': 'Confucius', 'category': 'Motivation'},
  {'text': 'Start where you are. Use what you have. Do what you can.', 'author': 'Arthur Ashe', 'category': 'Motivation'},
  {'text': 'Act as if what you do makes a difference. It does.', 'author': 'William James', 'category': 'Motivation'},
  {'text': 'Success is not final, failure is not fatal: it is the courage to continue that counts.', 'author': 'Winston Churchill', 'category': 'Motivation'},
  {'text': 'Do not wait. The time will never be just right.', 'author': 'Napoleon Hill', 'category': 'Motivation'},
  {'text': 'If you can dream it, you can do it.', 'author': 'Walt Disney', 'category': 'Motivation'},
  {'text': 'With the new day comes new strength and new thoughts.', 'author': 'Eleanor Roosevelt', 'category': 'Motivation'},
  {'text': 'The harder you work for something, the greater you will feel when you achieve it.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Dream bigger. Do bigger.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Failure will never overtake me if my determination to succeed is strong enough.', 'author': 'Og Mandino', 'category': 'Motivation'},
  {'text': 'If you are going through hell, keep going.', 'author': 'Winston Churchill', 'category': 'Motivation'},
  {'text': 'Push yourself, because no one else is going to do it for you.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Great things never come from comfort zones.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Dream it. Wish it. Do it.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Work hard in silence, let your success be your noise.', 'author': 'Frank Ocean', 'category': 'Motivation'},
  {'text': 'Do something today that your future self will thank you for.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Little things make big days.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'It is going to be hard, but hard does not mean impossible.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Do not stop when you are tired. Stop when you are done.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Wake up with determination. Go to bed with satisfaction.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Every day is a second chance.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Be the change you wish to see in the world.', 'author': 'Mahatma Gandhi', 'category': 'Motivation'},
  {'text': 'What you get by achieving your goals is not as important as what you become by achieving your goals.', 'author': 'Zig Ziglar', 'category': 'Motivation'},
  {'text': 'Whether you think you can or you think you cannot — you are right.', 'author': 'Henry Ford', 'category': 'Motivation'},
  {'text': 'Keep your face always toward the sunshine, and shadows will fall behind you.', 'author': 'Walt Whitman', 'category': 'Motivation'},
  {'text': 'The most common way people give up their power is by thinking they do not have any.', 'author': 'Alice Walker', 'category': 'Motivation'},
  {'text': 'Success usually comes to those who are too busy to be looking for it.', 'author': 'Henry David Thoreau', 'category': 'Motivation'},
  {'text': 'I find that the harder I work, the more luck I seem to have.', 'author': 'Thomas Jefferson', 'category': 'Motivation'},
  {'text': 'Do not be afraid to give up the good to go for the great.', 'author': 'John D. Rockefeller', 'category': 'Motivation'},
  {'text': 'There are two types of people who will tell you that you cannot make a difference in this world: those who are afraid to try and those who are afraid you will succeed.', 'author': 'Ray Goforth', 'category': 'Motivation'},
  {'text': 'I have not failed. I have just found 10,000 ways that will not work.', 'author': 'Thomas Edison', 'category': 'Motivation'},
  {'text': 'Opportunities do not happen. You create them.', 'author': 'Chris Grosser', 'category': 'Motivation'},
  {'text': 'Nothing in life is worthwhile unless you take risks.', 'author': 'Denzel Washington', 'category': 'Motivation'},
  {'text': 'It is never too late to be what you might have been.', 'author': 'George Eliot', 'category': 'Motivation'},
  {'text': 'You can never cross the ocean until you have the courage to lose sight of the shore.', 'author': 'Christopher Columbus', 'category': 'Motivation'},
  {'text': 'Life is not measured by the number of breaths we take, but by the moments that take our breath away.', 'author': 'Maya Angelou', 'category': 'Motivation'},
  {'text': 'If you want to lift yourself up, lift up someone else.', 'author': 'Booker T. Washington', 'category': 'Motivation'},
  {'text': 'Things do not happen. Things are made to happen.', 'author': 'John F. Kennedy', 'category': 'Motivation'},
  {'text': 'The best time to plant a tree was 20 years ago. The second best time is now.', 'author': 'Chinese Proverb', 'category': 'Motivation'},
  {'text': 'You must be the change you wish to see in the world.', 'author': 'Mahatma Gandhi', 'category': 'Motivation'},
  {'text': 'Motivation is what gets you started. Habit is what keeps you going.', 'author': 'Jim Ryun', 'category': 'Motivation'},
  {'text': 'Try to be a rainbow in someone\'s cloud.', 'author': 'Maya Angelou', 'category': 'Motivation'},
  {'text': 'Your time is limited, so do not waste it living someone else\'s life.', 'author': 'Steve Jobs', 'category': 'Motivation'},
  {'text': 'Either you run the day, or the day runs you.', 'author': 'Jim Rohn', 'category': 'Motivation'},
  {'text': 'It is not about how bad you want it. It is about how hard you are willing to work for it.', 'author': 'Anonymous', 'category': 'Motivation'},
  {'text': 'Success is liking yourself, liking what you do, and liking how you do it.', 'author': 'Maya Angelou', 'category': 'Motivation'},
  {'text': 'Knowing is not enough; we must apply. Willing is not enough; we must do.', 'author': 'Johann Wolfgang von Goethe', 'category': 'Motivation'},
  {'text': 'Nothing is impossible. The word itself says "I\'m possible."', 'author': 'Audrey Hepburn', 'category': 'Motivation'},
  {'text': 'Do what you can, where you are, with what you have.', 'author': 'Theodore Roosevelt', 'category': 'Motivation'},
  {'text': 'You just cannot beat the person who never gives up.', 'author': 'Babe Ruth', 'category': 'Motivation'},
  {'text': 'Strength does not come from physical capacity. It comes from an indomitable will.', 'author': 'Mahatma Gandhi', 'category': 'Motivation'},
  {'text': 'A person who never made a mistake never tried anything new.', 'author': 'Albert Einstein', 'category': 'Motivation'},
  {'text': 'The secret to getting ahead is getting started.', 'author': 'Mark Twain', 'category': 'Motivation'},
  {'text': 'Energy and persistence conquer all things.', 'author': 'Benjamin Franklin', 'category': 'Motivation'},
  {'text': 'Do not watch the clock. Do what it does. Keep going.', 'author': 'Sam Levenson', 'category': 'Motivation'},
  {'text': 'Nothing will work unless you do.', 'author': 'Maya Angelou', 'category': 'Motivation'},
  {'text': 'Perfection is not attainable, but if we chase perfection we can catch excellence.', 'author': 'Vince Lombardi', 'category': 'Motivation'},

  // ─────────────────────────────────────────
  // LIFE (quotes 261–320)
  // ─────────────────────────────────────────

  {'text': 'Life is what happens when you are busy making other plans.', 'author': 'John Lennon', 'category': 'Life'},
  {'text': 'Life is short, and it is up to you to make it sweet.', 'author': 'Sarah Louise Delany', 'category': 'Life'},
  {'text': 'In the end, it is not the years in your life that count. It is the life in your years.', 'author': 'Abraham Lincoln', 'category': 'Life'},
  {'text': 'Keep smiling, because life is a beautiful thing and there is so much to smile about.', 'author': 'Marilyn Monroe', 'category': 'Life'},
  {'text': 'Life is either a daring adventure or nothing at all.', 'author': 'Helen Keller', 'category': 'Life'},
  {'text': 'In three words I can sum up everything I have learned about life: it goes on.', 'author': 'Robert Frost', 'category': 'Life'},
  {'text': 'Life is not measured by the number of breaths we take, but by the moments that take our breath away.', 'author': 'Maya Angelou', 'category': 'Life'},
  {'text': 'Do not take life too seriously. You will never get out of it alive.', 'author': 'Elbert Hubbard', 'category': 'Life'},
  {'text': 'Go confidently in the direction of your dreams. Live the life you have imagined.', 'author': 'Henry David Thoreau', 'category': 'Life'},
  {'text': 'Life itself is the most wonderful fairy tale.', 'author': 'Hans Christian Andersen', 'category': 'Life'},
  {'text': 'The good life is one inspired by love and guided by knowledge.', 'author': 'Bertrand Russell', 'category': 'Life'},
  {'text': 'Do not cry because it is over, smile because it happened.', 'author': 'Dr. Seuss', 'category': 'Life'},
  {'text': 'Life is 10% what happens to you and 90% how you react to it.', 'author': 'Charles R. Swindoll', 'category': 'Life'},
  {'text': 'Nobody can go back and start a new beginning, but anyone can start today and make a new ending.', 'author': 'Maria Robinson', 'category': 'Life'},
  {'text': 'Every moment is a fresh beginning.', 'author': 'T.S. Eliot', 'category': 'Life'},
  {'text': 'It is never too late to be what you might have been.', 'author': 'George Eliot', 'category': 'Life'},
  {'text': 'Turn your wounds into wisdom.', 'author': 'Oprah Winfrey', 'category': 'Life'},
  {'text': 'What we think, we become.', 'author': 'Buddha', 'category': 'Life'},
  {'text': 'The journey of a thousand miles begins with one step.', 'author': 'Lao Tzu', 'category': 'Life'},
  {'text': 'We know what we are, but know not what we may be.', 'author': 'William Shakespeare', 'category': 'Life'},
  {'text': 'Life shrinks or expands in proportion to one\'s courage.', 'author': 'Anaïs Nin', 'category': 'Life'},
  {'text': 'The biggest adventure you can take is to live the life of your dreams.', 'author': 'Oprah Winfrey', 'category': 'Life'},
  {'text': 'Your life does not get better by chance. It gets better by change.', 'author': 'Jim Rohn', 'category': 'Life'},
  {'text': 'Once you choose hope, anything is possible.', 'author': 'Christopher Reeve', 'category': 'Life'},
  {'text': 'A life without cause is a life without effect.', 'author': 'Paulo Coelho', 'category': 'Life'},
  {'text': 'If life were predictable it would cease to be life and be without flavor.', 'author': 'Eleanor Roosevelt', 'category': 'Life'},
  {'text': 'Life is not a problem to be solved, but a reality to be experienced.', 'author': 'Søren Kierkegaard', 'category': 'Life'},
  {'text': 'Life is really simple, but we insist on making it complicated.', 'author': 'Confucius', 'category': 'Life'},
  {'text': 'May you live all the days of your life.', 'author': 'Jonathan Swift', 'category': 'Life'},
  {'text': 'The good life consists in deriving happiness by using your signature strengths every day in the main realms of living.', 'author': 'Martin Seligman', 'category': 'Life'},
  {'text': 'You only live once, but if you do it right, once is enough.', 'author': 'Mae West', 'category': 'Life'},
  {'text': 'Life is what you make it. Always has been, always will be.', 'author': 'Eleanor Roosevelt', 'category': 'Life'},
  {'text': 'If you want to live a happy life, tie it to a goal, not to people or things.', 'author': 'Albert Einstein', 'category': 'Life'},
  {'text': 'Never let the fear of striking out keep you from playing the game.', 'author': 'Babe Ruth', 'category': 'Life'},
  {'text': 'Life is short, live it. Love is rare, grab it. Anger is bad, dump it. Fear is awful, face it. Memories are sweet, cherish it.', 'author': 'Anonymous', 'category': 'Life'},
  {'text': 'Be the kind of person that makes everyone feel like a someone.', 'author': 'Anonymous', 'category': 'Life'},
  {'text': 'Not how long, but how well you have lived is the main thing.', 'author': 'Seneca', 'category': 'Life'},
  {'text': 'The unexamined life is not worth living.', 'author': 'Socrates', 'category': 'Life'},
  {'text': 'Life can only be understood backwards; but it must be lived forwards.', 'author': 'Søren Kierkegaard', 'category': 'Life'},
  {'text': 'You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose.', 'author': 'Dr. Seuss', 'category': 'Life'},
  {'text': 'All our dreams can come true, if we have the courage to pursue them.', 'author': 'Walt Disney', 'category': 'Life'},
  {'text': 'Life is a journey that must be traveled no matter how bad the roads and accommodations.', 'author': 'Oliver Goldsmith', 'category': 'Life'},
  {'text': 'Everything you can imagine is real.', 'author': 'Pablo Picasso', 'category': 'Life'},
  {'text': 'There is only one way to avoid criticism: do nothing, say nothing, and be nothing.', 'author': 'Aristotle', 'category': 'Life'},
  {'text': 'The best and most beautiful things in the world cannot be seen or even touched — they must be felt with the heart.', 'author': 'Helen Keller', 'category': 'Life'},
  {'text': 'It is during our darkest moments that we must focus to see the light.', 'author': 'Aristotle', 'category': 'Life'},
  {'text': 'Spread love everywhere you go. Let no one ever come to you without leaving happier.', 'author': 'Mother Teresa', 'category': 'Life'},
  {'text': 'When you reach the end of your rope, tie a knot in it and hang on.', 'author': 'Franklin D. Roosevelt', 'category': 'Life'},
  {'text': 'Always remember that you are absolutely unique. Just like everyone else.', 'author': 'Margaret Mead', 'category': 'Life'},
  {'text': 'Do not go where the path may lead, go instead where there is no path and leave a trail.', 'author': 'Ralph Waldo Emerson', 'category': 'Life'},
  {'text': 'You will face many defeats in life, but never let yourself be defeated.', 'author': 'Maya Angelou', 'category': 'Life'},
  {'text': 'The greatest glory in living lies not in never falling, but in rising every time we fall.', 'author': 'Nelson Mandela', 'category': 'Life'},
  {'text': 'Life is not about waiting for the storm to pass. It is about learning how to dance in the rain.', 'author': 'Vivian Greene', 'category': 'Life'},
  {'text': 'What lies behind you and what lies in front of you pales in comparison to what lies inside of you.', 'author': 'Ralph Waldo Emerson', 'category': 'Life'},
  {'text': 'You cannot go back and change the beginning, but you can start where you are and change the ending.', 'author': 'C.S. Lewis', 'category': 'Life'},
  {'text': 'Wherever you go, go with all your heart.', 'author': 'Confucius', 'category': 'Life'},
  {'text': 'Yesterday is history, tomorrow is a mystery, today is a gift of God, which is why we call it the present.', 'author': 'Bill Keane', 'category': 'Life'},
  {'text': 'Many of life\'s failures are people who did not realize how close they were to success when they gave up.', 'author': 'Thomas Edison', 'category': 'Life'},
  {'text': 'You have to learn the rules of the game. And then you have to play better than anyone else.', 'author': 'Albert Einstein', 'category': 'Life'},
  {'text': 'There is no royal road to anything. One thing at a time, all things in succession.', 'author': 'J.G. Holland', 'category': 'Life'},

  // ─────────────────────────────────────────
  // TECHNOLOGY (quotes 321–370)
  // ─────────────────────────────────────────

  {'text': 'Technology is best when it brings people together.', 'author': 'Matt Mullenweg', 'category': 'Technology'},
  {'text': 'The science of today is the technology of tomorrow.', 'author': 'Edward Teller', 'category': 'Technology'},
  {'text': 'It has become appallingly obvious that our technology has exceeded our humanity.', 'author': 'Albert Einstein', 'category': 'Technology'},
  {'text': 'The real problem is not whether machines think but whether men do.', 'author': 'B.F. Skinner', 'category': 'Technology'},
  {'text': 'Technology is a useful servant but a dangerous master.', 'author': 'Christian Lous Lange', 'category': 'Technology'},
  {'text': 'Any sufficiently advanced technology is indistinguishable from magic.', 'author': 'Arthur C. Clarke', 'category': 'Technology'},
  {'text': 'The computer was born to solve problems that did not exist before.', 'author': 'Bill Gates', 'category': 'Technology'},
  {'text': 'We are stuck with technology when what we really want is just stuff that works.', 'author': 'Douglas Adams', 'category': 'Technology'},
  {'text': 'The advance of technology is based on making it fit in so that you do not really even notice it.', 'author': 'Bill Gates', 'category': 'Technology'},
  {'text': 'Technology like art is a soaring exercise of the human imagination.', 'author': 'Daniel Bell', 'category': 'Technology'},
  {'text': 'Software is a great combination between artistry and engineering.', 'author': 'Bill Gates', 'category': 'Technology'},
  {'text': 'First, solve the problem. Then, write the code.', 'author': 'John Johnson', 'category': 'Technology'},
  {'text': 'The best error message is the one that never shows up.', 'author': 'Thomas Fuchs', 'category': 'Technology'},
  {'text': 'Programming is not about what you know; it is about what you can figure out.', 'author': 'Chris Pine', 'category': 'Technology'},
  {'text': 'The most disruptive innovations often start out looking like toys.', 'author': 'Chris Dixon', 'category': 'Technology'},
  {'text': 'Move fast and break things. Unless you are breaking stuff, you are not moving fast enough.', 'author': 'Mark Zuckerberg', 'category': 'Technology'},
  {'text': 'If you are not embarrassed by the first version of your product, you have launched too late.', 'author': 'Reid Hoffman', 'category': 'Technology'},
  {'text': 'Innovation is the ability to see change as an opportunity, not a threat.', 'author': 'Steve Jobs', 'category': 'Technology'},
  {'text': 'Design is not just what it looks like and feels like. Design is how it works.', 'author': 'Steve Jobs', 'category': 'Technology'},
  {'text': 'Simplicity is the ultimate sophistication.', 'author': 'Leonardo da Vinci', 'category': 'Technology'},
  {'text': 'Stay hungry, stay foolish.', 'author': 'Steve Jobs', 'category': 'Technology'},
  {'text': 'The internet is becoming the town square for the global village of tomorrow.', 'author': 'Bill Gates', 'category': 'Technology'},
  {'text': 'Privacy is not something that I am merely entitled to, it is an absolute prerequisite.', 'author': 'Marlon Brando', 'category': 'Technology'},
  {'text': 'Data is the new oil.', 'author': 'Clive Humby', 'category': 'Technology'},
  {'text': 'The biggest risk is not taking any risk. In a world that is changing really quickly, the only strategy that is guaranteed to fail is not taking risks.', 'author': 'Mark Zuckerberg', 'category': 'Technology'},
  {'text': 'Your most unhappy customers are your greatest source of learning.', 'author': 'Bill Gates', 'category': 'Technology'},
  {'text': 'Code is like humor. When you have to explain it, it is bad.', 'author': 'Cory House', 'category': 'Technology'},
  {'text': 'Walking on water and developing software from a specification are easy if both are frozen.', 'author': 'Edward V. Berard', 'category': 'Technology'},
  {'text': 'The function of good software is to make the complex appear to be simple.', 'author': 'Grady Booch', 'category': 'Technology'},
  {'text': 'Programs must be written for people to read, and only incidentally for machines to execute.', 'author': 'Harold Abelson', 'category': 'Technology'},
  {'text': 'The art of programming is the art of organizing complexity.', 'author': 'Edsger W. Dijkstra', 'category': 'Technology'},
  {'text': 'Computers are useless. They can only give you answers.', 'author': 'Pablo Picasso', 'category': 'Technology'},
  {'text': 'There is no reason for any individual to have a computer in his home.', 'author': 'Ken Olsen', 'category': 'Technology'},
  {'text': 'Failure is an option here. If things are not failing, you are not innovating enough.', 'author': 'Elon Musk', 'category': 'Technology'},
  {'text': 'When something is important enough, you do it even if the odds are not in your favor.', 'author': 'Elon Musk', 'category': 'Technology'},
  {'text': 'I think it is possible for ordinary people to choose to be extraordinary.', 'author': 'Elon Musk', 'category': 'Technology'},
  {'text': 'Imagination is the source of every form of human achievement.', 'author': 'Ken Robinson', 'category': 'Technology'},
  {'text': 'The future is already here — it is just not very evenly distributed.', 'author': 'William Gibson', 'category': 'Technology'},
  {'text': 'User experience is everything. It always has been, but it is undervalued and underinvested in.', 'author': 'Evan Williams', 'category': 'Technology'},
  {'text': 'Focus on impact, not on process.', 'author': 'Mark Zuckerberg', 'category': 'Technology'},
  {'text': 'Done is better than perfect.', 'author': 'Sheryl Sandberg', 'category': 'Technology'},
  {'text': 'The best way to predict the future is to invent it.', 'author': 'Alan Kay', 'category': 'Technology'},
  {'text': 'Machine intelligence is the last invention that humanity will ever need to make.', 'author': 'Nick Bostrom', 'category': 'Technology'},
  {'text': 'Automation is good, so long as you know exactly where to put the machine.', 'author': 'Eliyahu Goldratt', 'category': 'Technology'},
  {'text': 'Technology is the campfire around which we tell our stories.', 'author': 'Laurie Anderson', 'category': 'Technology'},
  {'text': 'The goal of software engineering is to make things that appear to work well.', 'author': 'L. Peter Deutsch', 'category': 'Technology'},
  {'text': 'Do not worry about people stealing your design work. Worry about the day they stop.', 'author': 'Jeffrey Zeldman', 'category': 'Technology'},
  {'text': 'Measuring programming progress by lines of code is like measuring aircraft building progress by weight.', 'author': 'Bill Gates', 'category': 'Technology'},
  {'text': 'There are only two hard things in computer science: cache invalidation and naming things.', 'author': 'Phil Karlton', 'category': 'Technology'},
  {'text': 'Talk is cheap. Show me the code.', 'author': 'Linus Torvalds', 'category': 'Technology'},
  {'text': 'Truth can only be found in one place: the code.', 'author': 'Robert C. Martin', 'category': 'Technology'},

  // ─────────────────────────────────────────
  // LEADERSHIP (quotes 371–400)
  // ─────────────────────────────────────────

  {'text': 'A leader is one who knows the way, goes the way, and shows the way.', 'author': 'John C. Maxwell', 'category': 'Leadership'},
  {'text': 'The greatest leader is not necessarily the one who does the greatest things. He is the one that gets the people to do the greatest things.', 'author': 'Ronald Reagan', 'category': 'Leadership'},
  {'text': 'Before you are a leader, success is all about growing yourself. When you become a leader, success is all about growing others.', 'author': 'Jack Welch', 'category': 'Leadership'},
  {'text': 'Leadership is the capacity to translate vision into reality.', 'author': 'Warren Bennis', 'category': 'Leadership'},
  {'text': 'The art of leadership is saying no, not saying yes. It is very easy to say yes.', 'author': 'Tony Blair', 'category': 'Leadership'},
  {'text': 'You do not lead by hitting people over the head — that is assault, not leadership.', 'author': 'Dwight Eisenhower', 'category': 'Leadership'},
  {'text': 'Great leaders are almost always great simplifiers who can cut through argument, debate, and doubt to offer a solution everybody can understand.', 'author': 'Colin Powell', 'category': 'Leadership'},
  {'text': 'If your actions inspire others to dream more, learn more, do more and become more, you are a leader.', 'author': 'John Quincy Adams', 'category': 'Leadership'},
  {'text': 'Leadership is not about being in charge. It is about taking care of those in your charge.', 'author': 'Simon Sinek', 'category': 'Leadership'},
  {'text': 'People buy into the leader before they buy into the vision.', 'author': 'John C. Maxwell', 'category': 'Leadership'},
  {'text': 'Leaders must be close enough to relate to others, but far enough ahead to motivate them.', 'author': 'John C. Maxwell', 'category': 'Leadership'},
  {'text': 'A good leader takes a little more than his share of the blame, a little less than his share of the credit.', 'author': 'Arnold H. Glasgow', 'category': 'Leadership'},
  {'text': 'Innovation distinguishes between a leader and a follower.', 'author': 'Steve Jobs', 'category': 'Leadership'},
  {'text': 'Outstanding leaders go out of their way to boost the self-esteem of their personnel.', 'author': 'Sam Walton', 'category': 'Leadership'},
  {'text': 'The task of leadership is not to put greatness into humanity, but to elicit it, for the greatness is already there.', 'author': 'John Buchan', 'category': 'Leadership'},
  {'text': 'The very essence of leadership is that you have to have vision.', 'author': 'Theodore Hesburgh', 'category': 'Leadership'},
  {'text': 'Leadership is not a position or a title, it is action and example.', 'author': 'Cory Booker', 'category': 'Leadership'},
  {'text': 'Real leadership is leaders recognizing that they serve the people that they lead.', 'author': 'Pete Buttigieg', 'category': 'Leadership'},
  {'text': 'To lead people, walk beside them.', 'author': 'Lao Tzu', 'category': 'Leadership'},
  {'text': 'A true leader has the confidence to stand alone, the courage to make tough decisions, and the compassion to listen to the needs of others.', 'author': 'Douglas MacArthur', 'category': 'Leadership'},
  {'text': 'Example is not the main thing in influencing others. It is the only thing.', 'author': 'Albert Schweitzer', 'category': 'Leadership'},
  {'text': 'Management is doing things right; leadership is doing the right things.', 'author': 'Peter Drucker', 'category': 'Leadership'},
  {'text': 'The most powerful leadership tool you have is your own personal example.', 'author': 'John Wooden', 'category': 'Leadership'},
  {'text': 'A leader is best when people barely know he exists. When his work is done, his aim fulfilled, they will say: we did it ourselves.', 'author': 'Lao Tzu', 'category': 'Leadership'},
  {'text': 'Earn your leadership every day.', 'author': 'Michael Jordan', 'category': 'Leadership'},
  {'text': 'A great person attracts great people and knows how to hold them together.', 'author': 'Johann Wolfgang Von Goethe', 'category': 'Leadership'},
  {'text': 'Leaders think and talk about the solutions. Followers think and talk about the problems.', 'author': 'Brian Tracy', 'category': 'Leadership'},
  {'text': 'The key to successful leadership today is influence, not authority.', 'author': 'Ken Blanchard', 'category': 'Leadership'},
  {'text': 'Dictators ride to and fro upon tigers which they dare not dismount. And the tigers are getting hungry.', 'author': 'Winston Churchill', 'category': 'Leadership'},
  {'text': 'Do not follow where the path may lead. Go instead where there is no path and leave a trail.', 'author': 'Ralph Waldo Emerson', 'category': 'Leadership'},

];
```

---

## Translation table — SQLite structure

Add this second table to `database_helper.dart` inside `_onCreate`:

```dart
await db.execute('''
  CREATE TABLE translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    quote_id    INTEGER NOT NULL,
    language    TEXT NOT NULL,
    translated  TEXT NOT NULL
  )
''');
```

Query translations in `translate_screen.dart`:

```dart
Future<String?> getTranslation(int quoteId, String language) async {
  final db = await database;
  final rows = await db.query(
    'translations',
    where: 'quote_id = ? AND language = ?',
    whereArgs: [quoteId, language],
  );
  if (rows.isEmpty) return null;
  return rows.first['translated'] as String;
}

Future<void> saveTranslation(int quoteId, String language, String translated) async {
  final db = await database;
  await db.insert('translations', {
    'quote_id':   quoteId,
    'language':   language,
    'translated': translated,
  });
}
```

---

## Translate screen — API call (MyMemory free API)

```dart
Future<String> translateQuote(String text, String targetLang) async {
  final encoded = Uri.encodeComponent(text);
  final url = 'https://api.mymemory.translated.net/get?q=$encoded&langpair=en|$targetLang';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['responseData']['translatedText'];
  }
  throw Exception('Translation failed');
}
```

### Language codes for MyMemory

| Language | Code |
|---|---|
| Tamil | ta |
| Hindi | hi |
| Telugu | te |
| Kannada | kn |
| Malayalam | ml |
| French | fr |
| Spanish | es |
| German | de |
| Japanese | ja |
| Arabic | ar |

---

## Category summary

| Category | Count |
|---|---|
| Education | 60 |
| Sports | 70 |
| Entertainment | 70 |
| Motivation | 60 |
| Life | 60 |
| Technology | 50 |
| Leadership | 30 |
| **Total** | **400** |

---

## Notes

- All single quotes inside text use `\'` escape to avoid Dart string errors
- `is_liked` and `is_user_added` default to `0` in seed data — omit from map, DB defaults handle it
- Duplicate quote text across categories is intentional in a few cases where the same quote fits multiple themes
- Translation API (MyMemory) is free up to 5000 words/day — sufficient for internship demo
