import Foundation

/// Pre-baked `Book` analyses for every entry in `ClassicBooks.all`, so the
/// "Try one of these classics" row on Home works fully offline — no OpenAI
/// API key required. `BundledBooks.match(_:)` falls through to this map after
/// checking the existing trending titles.
enum BundledClassics {

    static let all: [String: Book] = [
        "pride and prejudice": Book(
            title: "Pride and Prejudice",
            author: "Jane Austen",
            summary: """
Pride and Prejudice follows Elizabeth Bennet, the second of five sisters in a Regency-era English family that must marry well to secure its future. Through her sharp wit, fierce independence, and willingness to be wrong, Elizabeth navigates the social codes of class, money, and marriage, gradually moving past her first impressions of the proud Mr. Darcy.

Austen uses the courtship plot to dissect pride, prejudice, vanity, and self-deception. Each major character — Darcy, Elizabeth, Mr. Collins, Lady Catherine, Wickham — embodies a different attitude toward status and self-knowledge, and the novel's turning points come when characters admit they have misread someone or themselves.

The book endures because it treats clear-sightedness as a moral virtue. Falling in love well, in Austen's world, requires the same discipline as thinking well: noticing your own biases, updating on evidence, and being humble enough to revise your verdicts about other people.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Notice one strong first impression you formed this week and write down the evidence behind it", "Chapter 3"),
                ("Tuesday", "Re-evaluate a person you judged too quickly and list one thing you may have gotten wrong", "Chapter 18"),
                ("Wednesday", "Practice saying what you actually think in a low-stakes conversation, the way Elizabeth does", "Chapter 31"),
                ("Thursday", "Identify one belief you hold that is closer to pride than principle, and name it", "Chapter 34"),
                ("Friday", "Write a short letter — not to send — explaining your side of a recent disagreement clearly and fairly", "Chapter 35"),
                ("Saturday", "Apologize, in person or in writing, for one specific misjudgment", "Chapter 58"),
                ("Sunday", "Reflect on how your self-image changed this week and what you're willing to update", "Chapter 60")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg",
            publishedYear: 1813,
            genre: "Classic Fiction",
            isbn: "9780141439518"
        ),

        "1984": Book(
            title: "1984",
            author: "George Orwell",
            summary: """
1984 imagines a totalitarian future in which the Party, led by the mythic figure of Big Brother, controls every aspect of life in Oceania — language, history, sex, memory, and thought itself. Winston Smith, a low-level Party member who rewrites old newspapers to match the current Party line, begins to keep a forbidden diary and falls into a doomed love affair with Julia.

Orwell uses Winston's slow rebellion and eventual destruction to dramatize how power maintains itself: by controlling the past, by reshaping language (Newspeak) to make dissenting thought literally unspeakable, and by demanding not just obedience but love. The book introduces concepts — doublethink, thoughtcrime, the memory hole — that have become permanent fixtures in how we describe propaganda and surveillance.

The novel's lasting power is its insistence that freedom begins with private clarity: the right to say two plus two equals four, to remember what actually happened, and to keep an interior life that has not been edited by authority.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Start a private notebook this week to record what you actually think, separate from what you post", "Part 1, Chapter 1"),
                ("Tuesday", "Notice one phrase in the news or at work that does the opposite of what it says", "Part 1, Chapter 4"),
                ("Wednesday", "Audit the apps and accounts tracking your behavior and turn off one you don't need", "Part 1, Chapter 5"),
                ("Thursday", "Pick a current controversy and write down what each side actually believes, in their own terms", "Part 2, Chapter 5"),
                ("Friday", "Ask one person you trust what they really think about something you disagree on, and just listen", "Part 2, Chapter 8"),
                ("Saturday", "Identify one fact you hold because everyone says it, and check the primary source", "Part 3, Chapter 2"),
                ("Sunday", "Decide what you will not say or do under social pressure this coming week", "Part 3, Chapter 6")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg",
            publishedYear: 1949,
            genre: "Dystopian Fiction",
            isbn: "9780451524935"
        ),

        "to kill a mockingbird": Book(
            title: "To Kill a Mockingbird",
            author: "Harper Lee",
            summary: """
Set in Depression-era Alabama, To Kill a Mockingbird is narrated by Scout Finch, a girl growing up in the small town of Maycomb while her father, the lawyer Atticus Finch, defends Tom Robinson, a Black man falsely accused of assaulting a white woman. The novel weaves Scout's coming-of-age — her games with her brother Jem and the mysterious Boo Radley — with a clear-eyed look at the racial injustice surrounding the trial.

Through Atticus, Lee argues that moral courage is local and ordinary: it shows up in how you talk to neighbors, raise children, and stand alone when a community is wrong. The "mockingbird" is the innocent person — Tom Robinson, Boo Radley — destroyed by people who could have chosen otherwise.

The book endures because it asks small, hard questions: Whose perspective haven't you considered? Where are you going along with something you know is wrong? What would it cost you to behave decently when nobody else is?
""",
            actionableSteps: classicDetailed([
                ("Monday", "Pick one person you find hard to understand and spend a day imagining the world from their angle", "Chapter 3"),
                ("Tuesday", "Speak up once this week when you hear a casual remark you disagree with", "Chapter 9"),
                ("Wednesday", "Do one small act of consideration for a neighbor without expecting anything back", "Chapter 11"),
                ("Thursday", "Notice an assumption you made about someone based on appearance, and test it", "Chapter 15"),
                ("Friday", "When something is wrong at work or in your circle, write down what an honest response would be", "Chapter 20"),
                ("Saturday", "Have a real conversation with a child or younger person about something that matters", "Chapter 23"),
                ("Sunday", "Reflect on one moment you stayed silent this week and what you'd do differently", "Chapter 31")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg",
            publishedYear: 1960,
            genre: "Classic Fiction",
            isbn: "9780061120084"
        ),

        "the great gatsby": Book(
            title: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            summary: """
Narrated by Nick Carraway, The Great Gatsby unfolds across a single Long Island summer in 1922, as Nick is drawn into the orbit of his enigmatic neighbor Jay Gatsby — a self-made millionaire throwing extravagant parties in the hope of winning back Daisy Buchanan, the woman he loved before the war and before he had money.

Fitzgerald uses the love triangle of Gatsby, Daisy, and her brutal husband Tom to interrogate the American Dream: the belief that reinvention, wealth, and longing can rewrite the past. Gatsby's tragedy is not that he wants Daisy but that he wants what she symbolizes — a version of himself that the country's class structure will never let him keep.

The novel's enduring lesson is that what we chase often says more about who we wish we were than about the thing itself. The green light at the end of Daisy's dock is always one boat-length away.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Write down the life you imagine yourself having in five years and the feelings behind it", "Chapter 1"),
                ("Tuesday", "Ask yourself who, exactly, you are trying to impress with your next big purchase or move", "Chapter 3"),
                ("Wednesday", "Identify one part of your past you keep trying to rewrite and accept it as it was", "Chapter 6"),
                ("Thursday", "Spend an hour with someone you'd value even if neither of you had money or status", "Chapter 7"),
                ("Friday", "Examine one relationship for what it actually is versus what you wish it were", "Chapter 7"),
                ("Saturday", "Notice one symbol (a job title, a neighborhood, a car) you've mistaken for the thing itself", "Chapter 8"),
                ("Sunday", "Decide one thing you will stop pursuing because it represents an old self you've outgrown", "Chapter 9")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg",
            publishedYear: 1925,
            genre: "Classic Fiction",
            isbn: "9780743273565"
        ),

        "brave new world": Book(
            title: "Brave New World",
            author: "Aldous Huxley",
            summary: """
Set in a future World State where humans are mass-produced in hatcheries and conditioned from birth to love their predetermined caste, Brave New World follows Bernard Marx and Lenina Crowne as they meet John "the Savage," a young man raised on a Native American reservation outside the system. John's collision with the World State exposes a society that has traded freedom, family, art, and suffering for stability, pleasure, and the drug soma.

Huxley's dystopia is the mirror of Orwell's: nobody is repressed, because everyone is satisfied. Citizens are kept compliant not by terror but by endless distraction, casual sex, consumer novelty, and chemical mood management.

The book endures because the question it asks — what do you lose when you optimize for comfort? — is more relevant in an age of streaming feeds and on-demand dopamine than it was in 1932. Meaning, Huxley argues, requires the right to be unhappy.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Track how much of your day is spent on distraction-feeling pleasure versus deliberate effort", "Chapter 3"),
                ("Tuesday", "Pick one source of constant background distraction and remove it for 24 hours", "Chapter 6"),
                ("Wednesday", "Do one hard thing today that you usually outsource to convenience", "Chapter 10"),
                ("Thursday", "Spend an hour with no input — no phone, no music, no screen — and notice what surfaces", "Chapter 12"),
                ("Friday", "Have one honest conversation about something uncomfortable instead of smoothing it over", "Chapter 13"),
                ("Saturday", "Identify one belief you hold because it was conditioned into you, not chosen", "Chapter 16"),
                ("Sunday", "Decide one form of difficulty you will keep in your life on purpose", "Chapter 17")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg",
            publishedYear: 1932,
            genre: "Dystopian Fiction",
            isbn: "9780060850524"
        ),

        "the catcher in the rye": Book(
            title: "The Catcher in the Rye",
            author: "J. D. Salinger",
            summary: """
The Catcher in the Rye is narrated by Holden Caulfield, a sixteen-year-old recounting a few days in New York City after he is expelled from Pencey Prep. Wandering hotels, bars, and old haunts, Holden rails against the "phonies" he sees everywhere — adults, classmates, performers — while quietly grieving his younger brother Allie and trying to figure out what kind of person he wants to be.

Salinger uses Holden's voice — sarcastic, vulnerable, contradictory — to capture the loneliness of late adolescence: the sense that the adult world is corrupt and the child's world is gone. The image of the "catcher in the rye" — catching children before they fall off a cliff into adulthood — is Holden's fantasy of protection in a world that didn't protect Allie.

The book endures because almost everyone, at some age, has been Holden: lonely, ironic, watching themselves perform, secretly hoping someone notices the real them underneath.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Write one paragraph in your own voice about how you're actually doing — no edits", "Chapter 1"),
                ("Tuesday", "Reach out to one person you've drifted from without making it a big thing", "Chapter 5"),
                ("Wednesday", "Notice one moment today you put on a performance, and let it drop the second time", "Chapter 9"),
                ("Thursday", "Sit with a difficult feeling for ten minutes without trying to fix or distract", "Chapter 13"),
                ("Friday", "Talk to someone younger than you and actually listen to what they care about", "Chapter 16"),
                ("Saturday", "Identify one thing you've been calling 'phony' that you're really just afraid of", "Chapter 22"),
                ("Sunday", "Ask for help, even small help, from one person you trust", "Chapter 25")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780316769488-L.jpg",
            publishedYear: 1951,
            genre: "Classic Fiction",
            isbn: "9780316769488"
        ),

        "crime and punishment": Book(
            title: "Crime and Punishment",
            author: "Fyodor Dostoevsky",
            summary: """
In 1860s St. Petersburg, the impoverished former student Raskolnikov convinces himself that an "extraordinary" man is permitted to break ordinary moral law for a great purpose. He murders a pawnbroker, then spends the rest of the novel undone by a guilt he never expected — paranoia, fever, half-confessions to friends, a magnetic detective named Porfiry circling him, and the steady moral presence of the prostitute Sonya, who reads him the story of Lazarus.

Dostoevsky uses the murder less as a crime plot than as a laboratory for one of the great questions of modern life: can a person reason their way around conscience? Raskolnikov's ideology collapses not because the police catch him but because his own psyche refuses to ratify what his theory permitted.

The novel endures because it shows redemption as something specific and humble: confession, suffering accepted rather than rationalized, and the patient love of someone who refuses to give up on you.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Identify one rationalization you've been telling yourself and write the plain version next to it", "Part 1, Chapter 1"),
                ("Tuesday", "Notice when you treat a single ambition as more important than your ordinary obligations", "Part 1, Chapter 6"),
                ("Wednesday", "Confess one small thing — to a friend, a journal, a spouse — instead of letting it fester", "Part 2, Chapter 1"),
                ("Thursday", "Pay attention to physical symptoms (sleep, appetite, restlessness) as honest signals from your conscience", "Part 3, Chapter 2"),
                ("Friday", "Listen to someone whose worldview challenges yours instead of arguing them down", "Part 3, Chapter 5"),
                ("Saturday", "Do one quiet, specific act of restitution for a person you've wronged", "Part 5, Chapter 4"),
                ("Sunday", "Accept one consequence you've been avoiding, and stop running from it", "Epilogue, Chapter 2")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780143058144-L.jpg",
            publishedYear: 1866,
            genre: "Classic Fiction",
            isbn: "9780143058144"
        ),

        "moby-dick": Book(
            title: "Moby-Dick",
            author: "Herman Melville",
            summary: """
Narrated by Ishmael, Moby-Dick follows the whaling ship Pequod and its captain Ahab on a voyage that becomes a monomaniacal hunt for the white whale that took Ahab's leg. Around the chase, Melville packs encyclopedic chapters on whales, ropes, oil, race, work, and the doctrines of half a dozen religions, building one of the most ambitious novels in English.

Ahab embodies the seduction of a single defining goal: clarity, identity, and meaning purchased by reducing the world to one enemy. Ishmael, by contrast, survives because he stays curious, makes friends across races and creeds (Queequeg above all), and refuses to collapse the world into one story.

The novel endures because it lets you feel both pulls at once: the grandeur of giving your life to one thing, and the cost of letting that one thing eat everything else.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Name the 'white whale' you're chasing right now and write what winning would actually look like", "Chapter 1: Loomings"),
                ("Tuesday", "Identify one friendship you've under-invested in and schedule something specific", "Chapter 10: A Bosom Friend"),
                ("Wednesday", "Audit how much of your work is craft and how much is grievance", "Chapter 36: The Quarter-Deck"),
                ("Thursday", "Pick one subject outside your obsession and spend an hour learning about it", "Chapter 32: Cetology"),
                ("Friday", "Notice one place you've stopped asking advice because you've already decided", "Chapter 99: The Doubloon"),
                ("Saturday", "Take a deliberate rest from your chase and see what the world looks like without it", "Chapter 114: The Gilder"),
                ("Sunday", "Ask whether the cost of your current goal is still worth the prize, and adjust", "Chapter 135: The Chase—Third Day")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780142437247-L.jpg",
            publishedYear: 1851,
            genre: "Classic Fiction",
            isbn: "9780142437247"
        ),

        "jane eyre": Book(
            title: "Jane Eyre",
            author: "Charlotte Brontë",
            summary: """
Jane Eyre tells the life of its orphaned narrator from her abusive childhood at Gateshead, through the cold charity of Lowood School, into her position as governess at Thornfield Hall under the brooding Mr. Rochester. When Jane discovers the secret Rochester is hiding, she chooses self-respect over love and reinvents her life on her own terms before the novel's final reckoning.

Brontë wrote a heroine who refuses to be small. Jane's defining moments — answering back her aunt, leaving Rochester, returning only when she can do so as an equal — argue that conscience and self-possession are non-negotiable, even when they cost you everything you want.

The novel endures because it treats integrity as a kind of love: love of yourself, of the truth, and of the people you refuse to settle for less of.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Identify one boundary you've been afraid to state plainly, and state it", "Chapter 4"),
                ("Tuesday", "Take stock of where you've been mistreated and decide what is yours to address", "Chapter 8"),
                ("Wednesday", "Make one financial or practical move that makes you a little more independent", "Chapter 11"),
                ("Thursday", "Have a hard, honest conversation with someone you've been protecting from the truth", "Chapter 23"),
                ("Friday", "Walk away from one situation that asks you to compromise your self-respect", "Chapter 27"),
                ("Saturday", "Invest in a friendship or community outside your romantic life", "Chapter 30"),
                ("Sunday", "Return to a relationship or commitment only on terms you can live with", "Chapter 37")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141441146-L.jpg",
            publishedYear: 1847,
            genre: "Classic Fiction",
            isbn: "9780141441146"
        ),

        "wuthering heights": Book(
            title: "Wuthering Heights",
            author: "Emily Brontë",
            summary: """
Wuthering Heights tells the story of two intertwined families on the Yorkshire moors — the Earnshaws of Wuthering Heights and the Lintons of Thrushcross Grange — and the destructive love between Catherine Earnshaw and the foundling Heathcliff. The novel, framed by the tenant Lockwood and the housekeeper Nelly Dean, spans two generations as Heathcliff's vengeance for Catherine's marriage to Edgar Linton consumes nearly everyone around him.

Brontë gives us love not as redemption but as obsession: a force that, when refused its proper object, deforms every other relationship it touches. The book interrogates class, inheritance, and what unhealed grief can do across generations.

It endures because it refuses to make passion safe. The moor is beautiful and the wind is real, but the price of choosing nothing but feeling is the wreckage of two families and a century of unhappiness.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Name one passion in your life and ask whether it's serving you or running you", "Chapter 3"),
                ("Tuesday", "Identify a grudge you've been carrying and write what it has cost you", "Chapter 9"),
                ("Wednesday", "Choose one decision you've been making out of revenge and make a different one", "Chapter 17"),
                ("Thursday", "Talk to a younger family member about a family pattern they're inheriting", "Chapter 22"),
                ("Friday", "Forgive one person — at least in your own head — without requiring them to ask", "Chapter 27"),
                ("Saturday", "Spend time outdoors paying attention to the landscape instead of your inner storm", "Chapter 32"),
                ("Sunday", "Decide one cycle that ends with you, not your children", "Chapter 34")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439556-L.jpg",
            publishedYear: 1847,
            genre: "Classic Fiction",
            isbn: "9780141439556"
        ),

        "the odyssey": Book(
            title: "The Odyssey",
            author: "Homer",
            summary: """
The Odyssey follows Odysseus's ten-year voyage home from the Trojan War — through the land of the Lotus-eaters, the cave of the Cyclops, the seductions of Circe and Calypso, the underworld, and the deadly straits of Scylla and Charybdis — while back in Ithaca his wife Penelope holds off a hall full of suitors and his son Telemachus comes of age.

Homer uses the journey to argue that homecoming is not a place but a practice: of cunning over force, hospitality over violence, patience over appetite. Odysseus's heroism is not his strength but his disguise, his strategy, and his refusal to lose sight of who and what he is trying to return to.

The poem endures because the questions it asks — How do you keep yourself intact through years away from what you love? How do you come home and still know how to be there? — never get easier.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Define what 'home' actually means for you right now, beyond geography", "Book 1"),
                ("Tuesday", "Pick one situation where you've been using force when cunning would serve better", "Book 9"),
                ("Wednesday", "Notice one 'lotus' in your life — a comfort you stay in too long — and step out of it", "Book 9"),
                ("Thursday", "Have a guest, friend, or stranger over and practice real hospitality", "Book 14"),
                ("Friday", "Test the loyalty of a habit or commitment by stripping away its rewards for a day", "Book 17"),
                ("Saturday", "Reconnect with someone who has been waiting on you for too long", "Book 19"),
                ("Sunday", "Decide what you have to put right before you can fully arrive back where you belong", "Book 23")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780140268867-L.jpg",
            publishedYear: -700,
            genre: "Classic Literature",
            isbn: "9780140268867"
        ),

        "meditations": Book(
            title: "Meditations",
            author: "Marcus Aurelius",
            summary: """
Meditations is the private notebook of the Roman emperor Marcus Aurelius, written in Greek during military campaigns and never meant for publication. Across twelve short books, Marcus reminds himself of Stoic principles he is trying to live: focus on what is in your control, accept what is not, treat other people as fellow citizens of reason, and prepare each morning for difficulty without resentment.

The text is repetitive on purpose. Marcus is rehearsing — coming back day after day to the same disciplines because the work of being a decent person under pressure is never done. He writes about anger, vanity, fear of death, and the seductions of luxury with the candor of someone who lost his temper yesterday and intends to do better today.

The book endures because it is the rare ancient philosophy that reads like a real human being talking to himself. It treats virtue as a daily practice rather than a doctrine, and it works as well in the twenty-first century as it did in the second.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Before getting out of bed, name three difficulties you may meet today and how you'll handle them", "Book 2"),
                ("Tuesday", "List what is in your control today versus what is not, and act only on the first column", "Book 5"),
                ("Wednesday", "Notice one moment of anger and let it pass without acting on it", "Book 11"),
                ("Thursday", "Spend ten minutes considering your own death without dread, just clearly", "Book 4"),
                ("Friday", "Do your job well today without needing it to be noticed or praised", "Book 7"),
                ("Saturday", "Treat one difficult person as a fellow human doing their best with what they know", "Book 8"),
                ("Sunday", "Review the week: what would Marcus's version of you have done differently?", "Book 12")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780812968255-L.jpg",
            publishedYear: 180,
            genre: "Philosophy",
            isbn: "9780812968255"
        ),

        "the art of war": Book(
            title: "The Art of War",
            author: "Sun Tzu",
            summary: """
The Art of War is a short Chinese military treatise from roughly the fifth century BCE, traditionally attributed to the general Sun Tzu. Across thirteen brief chapters it lays out a theory of conflict in which the highest skill is to win without fighting — through superior planning, terrain, intelligence, deception, timing, and the careful management of your own forces.

Sun Tzu's central claim is that battles are won before they are fought. Most defeats come from acting without information, fighting on someone else's ground, or persisting in losing positions out of pride. Conflict, in his framing, is mostly a test of self-knowledge: who you are, what you have, and what you can actually sustain.

The book endures because its principles transfer easily to negotiation, business, sport, and personal life. It's not really about war; it's about the discipline of seeing a situation clearly before you commit to it.
""",
            actionableSteps: classicDetailed([
                ("Monday", "List your real resources, allies, and constraints before starting any new project this week", "Chapter 1: Laying Plans"),
                ("Tuesday", "Identify one battle you're fighting that you should stop fighting", "Chapter 2: Waging War"),
                ("Wednesday", "For your top conflict, plan how you could 'win without fighting'", "Chapter 3: Attack by Stratagem"),
                ("Thursday", "Choose your terrain — when, where, and how you'll engage — instead of letting others choose", "Chapter 6: Weak Points and Strong"),
                ("Friday", "Vary your approach: surprise where you've been predictable", "Chapter 5: Energy"),
                ("Saturday", "Gather better information on the other side before your next big decision", "Chapter 13: The Use of Spies"),
                ("Sunday", "Review the week: which actions were strategy, and which were ego?", "Chapter 10: Terrain")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781590302255-L.jpg",
            publishedYear: -500,
            genre: "Philosophy",
            isbn: "9781590302255"
        ),

        "walden": Book(
            title: "Walden",
            author: "Henry David Thoreau",
            summary: """
In 1845 Henry David Thoreau built a small cabin on the shore of Walden Pond in Concord, Massachusetts, and spent just over two years there in a deliberate experiment in simple living. Walden is the book he made of that experience: part memoir, part natural history, part argument that most people spend their lives buying things they don't need with hours they cannot get back.

Thoreau walks the reader through the economy of his cabin, the seasons of the pond, his visitors, his reading, and his thoughts on work, government, and conscience. The famous lines — "the mass of men lead lives of quiet desperation," "I went to the woods because I wished to live deliberately" — come from his attempt to figure out how much life actually costs in time, and whether the trade most of us make is a good one.

The book endures because it treats simplicity not as deprivation but as design: a way of clearing the room so the important things have somewhere to sit.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Calculate the true hourly cost of one expense by dividing it by the hours you worked for it", "Chapter 1: Economy"),
                ("Tuesday", "Identify three possessions you can live without and remove them this week", "Chapter 1: Economy"),
                ("Wednesday", "Schedule one hour outdoors with no phone, just paying attention", "Chapter 2: Where I Lived"),
                ("Thursday", "Replace one digital input with thirty minutes of a serious book", "Chapter 3: Reading"),
                ("Friday", "Eat one simple meal made from few ingredients, slowly, with no screen", "Chapter 11: Higher Laws"),
                ("Saturday", "Sit alone for an hour and notice what your mind does without inputs", "Chapter 5: Solitude"),
                ("Sunday", "Define what 'enough' looks like for you in money, things, and obligations", "Chapter 18: Conclusion")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780691096124-L.jpg",
            publishedYear: 1854,
            genre: "Philosophy",
            isbn: "9780691096124"
        ),

        "frankenstein": Book(
            title: "Frankenstein",
            author: "Mary Shelley",
            summary: """
Frankenstein is narrated through nested letters and confessions: an Arctic explorer named Walton recounts the dying testimony of Victor Frankenstein, the Genevan student who assembled a living creature from corpses and then abandoned him in horror. The creature, intelligent and eloquent, learns language and morality alone, discovers he will never be loved, and turns his grief into vengeance against his maker.

Shelley wrote a novel about responsibility. Victor is not punished for ambition but for what he refused to do after his ambition succeeded: care for what he had brought into the world. Every catastrophe in the book follows from that one abdication.

The novel endures because the question is permanent. Whenever we make something — a child, a company, an algorithm, an idea — we are also making the obligation to keep tending it.
""",
            actionableSteps: classicDetailed([
                ("Monday", "List the things you have 'created' (projects, relationships, products) and whether you've kept tending them", "Chapter 4"),
                ("Tuesday", "Re-engage with one project you started and walked away from, or formally end it", "Chapter 5"),
                ("Wednesday", "Acknowledge to someone you brought into a situation — hire, mentee, partner — that you'll see it through", "Chapter 10"),
                ("Thursday", "Sit with the consequences of one ambition you achieved without thinking it through", "Chapter 13"),
                ("Friday", "Listen to a voice you've been refusing to hear — a child, an employee, a critic", "Chapter 17"),
                ("Saturday", "Decide one creation you will refuse to start because you can't sustain it", "Chapter 19"),
                ("Sunday", "Take responsibility for one outcome you've been blaming on others", "Chapter 24")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439471-L.jpg",
            publishedYear: 1818,
            genre: "Classic Fiction",
            isbn: "9780141439471"
        ),

        "the picture of dorian gray": Book(
            title: "The Picture of Dorian Gray",
            author: "Oscar Wilde",
            summary: """
The Picture of Dorian Gray follows a beautiful young man whose portrait, painted by his friend Basil Hallward, mysteriously begins to age and corrupt in his place while Dorian himself stays untouched. Encouraged by the cynical aesthete Lord Henry Wotton, Dorian gives himself to pleasure and cruelty, hides the painting in an attic, and watches as the canvas absorbs every sin he commits.

Wilde uses the conceit to skewer Victorian hypocrisy and to ask a serious question underneath the wit: what kind of person are you really, separate from the face you present? The painting is conscience made visible — and Dorian's tragedy is not that he has one but that he keeps locking it in the attic.

The novel endures because its setup translates perfectly to a curated digital life. We all have a portrait somewhere that doesn't match the timeline.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Write an honest description of your inner life that wouldn't fit on your public profile", "Chapter 2"),
                ("Tuesday", "Notice one influence in your life — a person, a feed, a habit — that flatters your worst instincts", "Chapter 4"),
                ("Wednesday", "Do one act privately that you'd want to do publicly, and one publicly that you've been hiding", "Chapter 7"),
                ("Thursday", "Look directly at a 'portrait' you've been avoiding — a number, a relationship, a feeling", "Chapter 13"),
                ("Friday", "Make one repair to your real life that you've been faking through your image", "Chapter 14"),
                ("Saturday", "Spend a day without curating yourself for anyone — clothes, posts, performance", "Chapter 16"),
                ("Sunday", "Decide what kind of person you actually want to become, separate from how you want to be seen", "Chapter 20")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439570-L.jpg",
            publishedYear: 1890,
            genre: "Classic Fiction",
            isbn: "9780141439570"
        ),

        "a tale of two cities": Book(
            title: "A Tale of Two Cities",
            author: "Charles Dickens",
            summary: """
Set in London and Paris in the years leading up to and through the French Revolution, A Tale of Two Cities follows the doctor Manette, freed from years of unjust imprisonment in the Bastille; his daughter Lucie; the French aristocrat Charles Darnay, who renounces his family's cruelties; and the dissolute English lawyer Sydney Carton, who looks uncannily like Darnay and is in love with Lucie.

Dickens weaves private grief and public revolution into a single fabric. The cycles of cruelty that produced the Revolution are real, and so are the revolutionaries' new cruelties; only individual acts of mercy interrupt them. Sydney Carton's final choice — taking Darnay's place at the guillotine — is the novel's argument that one ordinary person's redemption can outweigh a great deal of inherited evil.

The novel endures because it is honest about how injustice multiplies and how rare and costly it is to break the chain.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Identify one inherited grievance you're still carrying that didn't start with you", "Book 1, Chapter 1"),
                ("Tuesday", "Step out of one cycle of resentment by refusing to repeat it once this week", "Book 2, Chapter 9"),
                ("Wednesday", "Help one person whose situation you'd normally judge from a distance", "Book 2, Chapter 14"),
                ("Thursday", "Notice when your sense of justice has slid into a taste for revenge", "Book 3, Chapter 5"),
                ("Friday", "Take responsibility for one consequence of your family's history that's yours to address", "Book 3, Chapter 8"),
                ("Saturday", "Choose to do something quietly costly for someone who can't repay you", "Book 3, Chapter 13"),
                ("Sunday", "Define what 'a far, far better thing' would mean for you in a small, concrete way", "Book 3, Chapter 15")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439600-L.jpg",
            publishedYear: 1859,
            genre: "Classic Fiction",
            isbn: "9780141439600"
        ),

        "great expectations": Book(
            title: "Great Expectations",
            author: "Charles Dickens",
            summary: """
Great Expectations is narrated by Pip, a poor orphan in the Kentish marshes who is suddenly given a secret fortune and the chance to become a gentleman in London. He assumes his benefactor is the eccentric Miss Havisham, grooming him for her ward Estella, and reshapes his life around that assumption — until the truth about who is really funding him arrives at his door.

Dickens uses Pip's three-stage education to interrogate ambition, shame, and class. The harder Pip works to escape his origins, the more clearly we see what he abandons — Joe Gargery, Biddy, the people who loved him before he was worth anything to anyone. The novel's quiet thesis is that gentility is not a class but a way of treating other people.

The book endures because nearly everyone, at some point, mistakes a story about themselves for the truth and has to grow up by giving it up.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Write down the 'expectations' you secretly hold about how your life will unfold", "Chapter 8"),
                ("Tuesday", "Identify one person you've been ashamed of and reconnect with them honestly", "Chapter 27"),
                ("Wednesday", "Examine where your money or status actually came from, and what you owe to that source", "Chapter 39"),
                ("Thursday", "Stop performing 'made it' to one audience that doesn't matter", "Chapter 48"),
                ("Friday", "Make right one debt — financial, emotional, or moral — that has been sitting too long", "Chapter 53"),
                ("Saturday", "Tell someone who supported you early what their support meant", "Chapter 57"),
                ("Sunday", "Define success on terms your younger self would actually respect", "Chapter 59")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439563-L.jpg",
            publishedYear: 1861,
            genre: "Classic Fiction",
            isbn: "9780141439563"
        ),

        "the brothers karamazov": Book(
            title: "The Brothers Karamazov",
            author: "Fyodor Dostoevsky",
            summary: """
The Brothers Karamazov centers on the murder of the dissolute landowner Fyodor Karamazov and the four men who could plausibly have done it — his sons Dmitri the soldier, Ivan the intellectual, Alyosha the novice monk, and the bastard Smerdyakov. Around the crime, Dostoevsky builds a vast novel about doubt and faith, freedom and responsibility, and what people owe each other when no one is watching.

Each brother carries a different answer to the question of how to live without God's certainty: Dmitri's passion, Ivan's reason, Alyosha's love, Smerdyakov's nihilism. The chapter "The Grand Inquisitor" is the most famous philosophical set piece in the novel — a dialogue between freedom and security that has been quoted by theologians and political theorists for a century.

The novel endures because it insists that we are responsible for everyone and everything, not in theory but in the specific, daily way Alyosha tries to practice.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Write down what you actually believe is true about the universe — short, in your own words", "Book 1"),
                ("Tuesday", "Pick one place you've reasoned yourself out of a moral obligation and reconsider", "Book 5: Pro and Contra"),
                ("Wednesday", "Take responsibility for one situation in your circle that you usually treat as someone else's", "Book 6"),
                ("Thursday", "Forgive someone privately without making it about you", "Book 7"),
                ("Friday", "Sit with a doubt instead of fixing it, and notice what it teaches you", "Book 11"),
                ("Saturday", "Spend an hour with a child or younger person and take what they say seriously", "Book 10"),
                ("Sunday", "Choose love over being right in one specific conversation this week", "Epilogue")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780374528379-L.jpg",
            publishedYear: 1880,
            genre: "Classic Fiction",
            isbn: "9780374528379"
        ),

        "anna karenina": Book(
            title: "Anna Karenina",
            author: "Leo Tolstoy",
            summary: """
Anna Karenina braids two long storylines through 1870s Russia: the doomed affair of Anna, a beautiful Petersburg aristocrat, with the cavalry officer Vronsky; and the slow, awkward courtship and marriage of the landowner Levin and the young Kitty Shcherbatskaya. The novel opens with one of literature's most famous lines about happy and unhappy families, and proceeds to test it across hundreds of pages of social custom, farming, politics, and inner life.

Tolstoy puts Anna's tragedy and Levin's quiet building of a life side by side on purpose. Anna chases a feeling that society will not let her keep; Levin builds a marriage, a farm, and a faith that nobody else can give him. The book argues, without lecturing, that meaning is mostly made in the unglamorous parts of life.

It endures because it gives full dignity to both paths — passion and patience — and shows the real cost of each.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Audit which of your relationships you've been performing in front of an imagined audience", "Part 1, Chapter 1"),
                ("Tuesday", "Invest one hour in physical work — gardening, cooking, building — and notice how you feel", "Part 3, Chapter 4"),
                ("Wednesday", "Have one slow, undistracted conversation with your partner or closest friend", "Part 4, Chapter 14"),
                ("Thursday", "Identify one passion you're treating as an identity and ask what it's costing you", "Part 5, Chapter 30"),
                ("Friday", "Step away from social comparison for a day — no feeds, no rankings", "Part 6, Chapter 21"),
                ("Saturday", "Plan something small and sustainable that you could keep doing for years", "Part 7, Chapter 16"),
                ("Sunday", "Reflect on what you actually believe about how to live, and write a paragraph", "Part 8, Chapter 12")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780143035008-L.jpg",
            publishedYear: 1877,
            genre: "Classic Fiction",
            isbn: "9780143035008"
        ),

        "war and peace": Book(
            title: "War and Peace",
            author: "Leo Tolstoy",
            summary: """
War and Peace follows five aristocratic Russian families — the Bezukhovs, Bolkonskys, Rostovs, Kuragins, and Drubetskoys — across the Napoleonic Wars, from the salons of Petersburg to the battlefields of Austerlitz and Borodino to Napoleon's catastrophic march on Moscow. Around them, Tolstoy interleaves long meditations on history, free will, and what really drives the events biographers later call great.

The two central figures, Pierre Bezukhov and Andrei Bolkonsky, search for meaning by very different routes — wealth, philosophy, war, religion, marriage, captivity — and arrive, slowly, at the same conviction: that life is lived in attention to ordinary people and ordinary days, not in grand designs.

The novel endures because it dignifies the small. History, in Tolstoy's hands, is not made by Napoleon but by the millions of choices made by ordinary people on the same day.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Notice one 'great' event in your life that was actually built from small choices, and credit them", "Volume 1, Part 1"),
                ("Tuesday", "Spend a day giving your full attention to small interactions instead of big plans", "Volume 1, Part 3"),
                ("Wednesday", "Step away from a 'historical' identity (job title, family role) and sit with who you are under it", "Volume 2, Part 2"),
                ("Thursday", "Talk to someone older about a war or upheaval they lived through, and just listen", "Volume 3, Part 2"),
                ("Friday", "Identify one cause you're chasing for the story and one for the substance", "Volume 3, Part 3"),
                ("Saturday", "Help one specific person rather than thinking about helping many", "Volume 4, Part 1"),
                ("Sunday", "Write down what you've come to believe about why things happen, in your own words", "Epilogue, Part 2")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781400079988-L.jpg",
            publishedYear: 1869,
            genre: "Classic Fiction",
            isbn: "9781400079988"
        ),

        "don quixote": Book(
            title: "Don Quixote",
            author: "Miguel de Cervantes",
            summary: """
Don Quixote tells the story of an aging Spanish gentleman so saturated by chivalric romances that he renames himself a knight, recruits the farmer Sancho Panza as his squire, and sets out across La Mancha to right wrongs that exist mostly in his head. He charges windmills he believes are giants, mistakes inns for castles and prostitutes for noblewomen, and is beaten, mocked, and adored across two long volumes.

Cervantes built the first modern novel out of a question: when is delusion noble and when is it harmful? Don Quixote's madness produces both real cruelty and real kindness, and the people around him are forced to decide what to do with someone whose inner world will not match the outer one.

The novel endures because it treats the impulse to live by a story as both ridiculous and necessary. Almost everyone is partly Don Quixote.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Name the story you're currently living inside — hero arc, underdog, victim — and see it clearly", "Part 1, Chapter 1"),
                ("Tuesday", "Pick one 'windmill' you've been charging and ask whether it's a real giant", "Part 1, Chapter 8"),
                ("Wednesday", "Take a sidekick or partner's perspective seriously instead of overruling it", "Part 1, Chapter 18"),
                ("Thursday", "Let yourself look foolish in service of something you actually care about", "Part 2, Chapter 17"),
                ("Friday", "Decide which parts of your romantic story to keep and which to put down", "Part 2, Chapter 32"),
                ("Saturday", "Treat an 'enchanter' (a force you blame everything on) as a story instead of a fact", "Part 2, Chapter 41"),
                ("Sunday", "Choose one ordinary act of decency that doesn't require a quest", "Part 2, Chapter 74")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780060934347-L.jpg",
            publishedYear: 1605,
            genre: "Classic Fiction",
            isbn: "9780060934347"
        ),

        "the iliad": Book(
            title: "The Iliad",
            author: "Homer",
            summary: """
The Iliad takes up a few weeks late in the tenth year of the Greek siege of Troy, after the Greek leader Agamemnon insults the warrior Achilles by taking his prize. Achilles withdraws from the war, the Greeks suffer, and the poem traces the consequences: the killing of Patroclus, Achilles's return to battle, the death of the Trojan prince Hector, and Hector's father Priam crossing enemy lines to beg his son's body back.

Homer is not interested in war as glory. He is interested in honor, grief, and the cost of pride — what it does to leaders, soldiers, families, and cities. The poem's most famous scene is not a battle but two enemies, Priam and Achilles, weeping together over the dead.

The Iliad endures because it shows that the deepest acts of humanity often happen on the worst day of a life, and they require seeing the enemy as a person.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Identify one slight that has been driving your behavior and ask whether it's worth what it's costing", "Book 1"),
                ("Tuesday", "Step back from a fight you're winning to ask whether you'd want what victory would bring", "Book 9"),
                ("Wednesday", "Acknowledge the impact of a decision you made in anger or pride", "Book 16"),
                ("Thursday", "Return what you've been holding onto out of spite — a grudge, a possession, a story", "Book 18"),
                ("Friday", "Grieve openly something you've been hiding the loss of", "Book 23"),
                ("Saturday", "Sit across from someone you consider an enemy and try to see them as a parent, child, or friend", "Book 24"),
                ("Sunday", "Decide one act of mercy you'll perform that gives you nothing in return", "Book 24")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780140275360-L.jpg",
            publishedYear: -750,
            genre: "Classic Literature",
            isbn: "9780140275360"
        ),

        "fahrenheit 451": Book(
            title: "Fahrenheit 451",
            author: "Ray Bradbury",
            summary: """
In Ray Bradbury's near-future America, books are illegal and houses are fireproof. Firemen, including the protagonist Guy Montag, are sent to burn any books that turn up. The citizens fill their walls with interactive screens and their ears with seashell radios, and most of them, Montag's wife Mildred included, can no longer hold a real conversation. When Montag meets a curious teenage neighbor and watches an old woman choose to die with her books, he begins to question what his work is actually for.

Bradbury wrote less about government censorship than about the public's appetite for distraction. The books in Fahrenheit 451 were burned because nobody was reading them anyway — because they slowed down a culture that wanted faster pleasures and fewer hard feelings.

The novel endures because its diagnosis fits the always-on present better than 1953. The threat to thought is not a fireman; it's an algorithm.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Audit your media diet for one day — what's input, what's just noise", "Part 1"),
                ("Tuesday", "Replace 30 minutes of feed with a book or a long-form article", "Part 1"),
                ("Wednesday", "Have one real conversation that lasts longer than 15 minutes", "Part 1"),
                ("Thursday", "Choose one uncomfortable idea you've been scrolling past and sit with it", "Part 2"),
                ("Friday", "Write down something you believe in your own words — no AI, no template", "Part 2"),
                ("Saturday", "Spend a day without quick entertainment and notice what fills the space", "Part 3"),
                ("Sunday", "Decide one book, idea, or practice you'd protect even if nobody else read it", "Part 3")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg",
            publishedYear: 1953,
            genre: "Dystopian Fiction",
            isbn: "9781451673319"
        ),

        "of mice and men": Book(
            title: "Of Mice and Men",
            author: "John Steinbeck",
            summary: """
Of Mice and Men follows two migrant ranch workers, the sharp George Milton and the physically enormous, mentally limited Lennie Small, as they arrive at a ranch in California's Salinas Valley during the Great Depression. They share a dream — a small farm of their own, with rabbits for Lennie to tend — and Steinbeck spends the short novel testing whether two friends and a modest hope can survive the conditions they live under.

Steinbeck packs the book into a few rooms — the bunkhouse, the barn, a stretch of riverbank — and a few days, and uses that compression to ask big questions about loneliness, dignity of labor, and the responsibility you take on when you love someone less powerful than you.

The novella endures because its ending makes you decide, over and over, what you would have done. The dream of "a place of our own" is a permanent American ache.
""",
            actionableSteps: classicDetailed([
                ("Monday", "Write down the modest, specific version of your dream — not the grand one", "Chapter 1"),
                ("Tuesday", "Identify one person in your life who depends on you, and re-commit to how you show up for them", "Chapter 2"),
                ("Wednesday", "Have one honest conversation with a coworker or peer you usually keep at a distance", "Chapter 3"),
                ("Thursday", "Notice one person on the margins of your circle and include them deliberately", "Chapter 4"),
                ("Friday", "Take responsibility for a consequence of someone you 'manage' or care for", "Chapter 5"),
                ("Saturday", "Spend a day doing physical work and notice what it costs and what it gives back", "Chapter 5"),
                ("Sunday", "Make one decision today the future version of you will be able to live with", "Chapter 6")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780140177398-L.jpg",
            publishedYear: 1937,
            genre: "Classic Fiction",
            isbn: "9780140177398"
        )
    ]

    /// Case-insensitive lookup mirroring `BundledBooks.match(_:)`.
    static func match(_ title: String) -> Book? {
        let key = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = all[key] { return exact }
        for (k, v) in all where k.contains(key) || key.contains(k) {
            return v
        }
        return nil
    }
}

/// File-local helper that mirrors `BundledBooks.detailed(_:)`. Generates the
/// `DetailedStepInfo` placeholder content for each (day, step, chapter) tuple
/// so the bundled classics carry the same shape as a live OpenAI analysis.
private func classicDetailed(_ tuples: [(String, String, String)]) -> [ActionableStep] {
    tuples.map { (day, step, chapter) in
        ActionableStep(
            step: step,
            chapter: chapter,
            day: day,
            details: DetailedStepInfo(
                sentences: [
                    "Pick a concrete time today to do this action — write it on your calendar before the day fills up.",
                    "Make the action specific: who, where, for how long, and how you'll know it's done.",
                    "Remove one friction in your environment that would let you skip it.",
                    "Notice one common excuse you'd reach for, and decide now how you'll answer it.",
                    "At the end of the day, write a single sentence about what changed or what you noticed."
                ],
                keyTakeaway: "The lesson connects directly to \(chapter): the work is to \(step.lowercased()), in small specific ways, until it becomes how you live rather than what you intend."
            )
        )
    }
}
