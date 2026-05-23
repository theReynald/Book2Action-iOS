import Foundation

/// Bundled book data used as offline fallbacks before the AI is called,
/// matching the original mobile app exactly.
enum BundledBooks {

    static let all: [String: Book] = [
        "atomic habits": Book(
            title: "Atomic Habits",
            author: "James Clear",
            summary: """
Atomic Habits presents a revolutionary approach to habit formation based on the principle that small changes can yield remarkable results when compounded over time. James Clear argues that we often overestimate the importance of one defining moment and underestimate the value of making small improvements on a daily basis. The book introduces the concept that if you get one percent better each day for one year, you will end up thirty-seven times better by the time you are done, demonstrating the mathematical power of marginal gains in personal development.

The core framework of the book revolves around the Four Laws of Behavior Change: make it obvious, make it attractive, make it easy, and make it satisfying. Clear systematically breaks down how habits work at a neurological level, explaining the habit loop of cue, craving, response, and reward. He demonstrates how environmental design plays a crucial role in habit formation, showing that motivation is often overrated while environment and systems design are underrated factors in creating lasting behavioral change.

The practical applications extend beyond personal development to professional growth, relationships, and health, with Clear introducing powerful techniques such as habit stacking, the two-minute rule, and environment design strategies. The book provides numerous real-world examples and case studies, from how the British cycling team dominated international competition through marginal gains to how businesses and individuals have transformed their lives through systematic habit design.
""",
            actionableSteps: detailed([
                ("Monday", "Start with habits so small they seem almost ridiculous (2-minute rule)", "Chapter 11: Walk Slowly, but Never Backward"),
                ("Tuesday", "Stack new habits onto existing ones using habit stacking", "Chapter 5: The Best Way to Start a New Habit"),
                ("Wednesday", "Design your environment to make good habits obvious and bad habits invisible", "Chapter 6: Motivation Is Overrated; Environment Often Matters More"),
                ("Thursday", "Track your habits daily using a simple habit tracker", "Chapter 16: How to Stick with Good Habits Every Day"),
                ("Friday", "Focus on identity-based habits: \"I am the type of person who...\"", "Chapter 2: How Your Habits Shape Your Identity"),
                ("Saturday", "Use the two-day rule: never miss twice in a row", "Chapter 15: The Cardinal Rule of Behavior Change"),
                ("Sunday", "Celebrate small wins immediately after completing a habit", "Chapter 15: The Cardinal Rule of Behavior Change")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
            publishedYear: 2018,
            genre: "Self-Help",
            isbn: "9780735211292"
        ),
        "think and grow rich": Book(
            title: "Think and Grow Rich",
            author: "Napoleon Hill",
            summary: """
Think and Grow Rich emerged from Napoleon Hill's twenty-year study of over 500 successful individuals, including Andrew Carnegie, Henry Ford, and Thomas Edison. The book presents thirteen fundamental principles for achieving wealth and success, based on Hill's analysis of what separates those who accumulate wealth from those who struggle financially.

The book introduces revolutionary concepts such as the "Master Mind" principle, which Hill defines as the coordination of knowledge and effort between two or more people working toward a definite purpose. He demonstrates how the most successful individuals surrounded themselves with advisors, mentors, and like-minded individuals who could provide specialized knowledge and support.

The lasting impact of Think and Grow Rich lies in its emphasis on personal responsibility and mental conditioning, with Hill arguing that circumstances do not make the person but rather reveal their character and mental attitude. The book provides a complete philosophy of personal achievement that extends beyond financial success to encompass happiness, health, and fulfillment.
""",
            actionableSteps: detailed([
                ("Monday", "Define your definite major purpose with specific financial goals", "Chapter 2: Desire"),
                ("Tuesday", "Develop burning desire by writing down exactly what you want", "Chapter 2: Desire"),
                ("Wednesday", "Build unwavering faith through auto-suggestion and visualization", "Chapter 3: Faith"),
                ("Thursday", "Acquire specialized knowledge in your chosen field", "Chapter 5: Specialized Knowledge"),
                ("Friday", "Use your imagination to create detailed plans for achieving your goals", "Chapter 6: Imagination"),
                ("Saturday", "Make quick, firm decisions and stick to them", "Chapter 8: Decision"),
                ("Sunday", "Develop persistence by never giving up on your major purpose", "Chapter 9: Persistence")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781585424337-L.jpg",
            publishedYear: 1937,
            genre: "Personal Finance",
            isbn: "9781585424337"
        ),
        "the 7 habits of highly effective people": Book(
            title: "The 7 Habits of Highly Effective People",
            author: "Stephen R. Covey",
            summary: """
The 7 Habits of Highly Effective People presents a principle-centered approach to personal and professional effectiveness that has transformed millions of lives. Stephen Covey introduces a paradigm shift from the "Personality Ethic" that focuses on quick-fix techniques and manipulation tactics to the "Character Ethic" that emphasizes fundamental principles and character development.

The first three habits focus on achieving private victory and personal mastery: Be Proactive (taking responsibility for your choices), Begin with the End in Mind (defining your values and life mission), and Put First Things First (managing yourself according to your priorities). The next three habits address public victory and effective interpersonal relationships.

What makes this book enduringly powerful is its emphasis on inside-out change, starting with self-mastery before attempting to influence others, demonstrating that quick fixes are superficial unless based on solid character and correct principles.
""",
            actionableSteps: detailed([
                ("Monday", "Be proactive: Focus on what you can control and take responsibility", "Habit 1: Be Proactive"),
                ("Tuesday", "Begin with the end in mind: Define your personal mission statement", "Habit 2: Begin with the End in Mind"),
                ("Wednesday", "Put first things first: Prioritize important over urgent tasks", "Habit 3: Put First Things First"),
                ("Thursday", "Think win-win: Seek mutual benefit in all interactions", "Habit 4: Think Win-Win"),
                ("Friday", "Seek first to understand, then to be understood: Practice empathetic listening", "Habit 5: Seek First to Understand, Then to Be Understood"),
                ("Saturday", "Synergize: Value differences and work collaboratively", "Habit 6: Synergize"),
                ("Sunday", "Sharpen the saw: Continuously improve in all four dimensions of life", "Habit 7: Sharpen the Saw")
            ]),
            coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781982137274-L.jpg",
            publishedYear: 1989,
            genre: "Self-Help",
            isbn: "9781982137274"
        )
    ]

    static func match(_ title: String) -> Book? {
        let key = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = all[key] { return exact }
        for (k, v) in all where k.contains(key) || key.contains(k) {
            return v
        }
        return nil
    }

    private static func detailed(_ tuples: [(String, String, String)]) -> [ActionableStep] {
        tuples.map { (day, step, chapter) in
            ActionableStep(
                step: step,
                chapter: chapter,
                day: day,
                details: DetailedStepInfo(
                    sentences: [
                        "This step helps you implement \"\(step)\" in your daily routine.",
                        "Based on the principles from \(chapter), this action creates lasting change.",
                        "Consistency with this practice leads to substantial improvements over time.",
                        "Many readers have reported that this specific technique leads to measurable results.",
                        "The author identifies this as a key principle for success in this area."
                    ],
                    keyTakeaway: "The core lesson is to \(step.lowercased()) with intention and consistency."
                )
            )
        }
    }
}
