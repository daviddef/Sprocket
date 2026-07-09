import SwiftUI

/// Explorers track — ages 9–12, the research "sweet spot." Concept + a
/// hands-on beat per unit ("train it, break it, fix it"). First real prompts.
/// Ethics stays woven through, framed as judgment, not fear.
extension Curriculum {
    static let explorers: [Unit] = [

        // 1 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.1", tier: .explorers, bigIdea: .perception, order: 1,
            title: "What Counts as AI?",
            subtitle: "Kinds of AI around you",
            symbol: "sparkles",
            screens: [
                .teach(TeachCard(
                    title: "AI Is Already Everywhere",
                    body: "Video recommendations, map directions, photo filters, spam blockers — lots of everyday tools quietly use AI.",
                    symbol: "square.grid.2x2.fill")),
                .teach(TeachCard(
                    title: "Narrow vs. General",
                    body: "Today's AI is 'narrow' — it's great at one job, like spotting faces. The all-knowing robot from movies ('general AI') doesn't exist yet.",
                    symbol: "target")),
                .game(.sort(SortGame(
                    title: "Spot the AI",
                    intro: "Sort each tool: does it use AI to make smart guesses, or does it just follow fixed rules?",
                    binA: .init(label: "Uses AI", symbol: "brain.head.profile", color: Theme.explorers),
                    binB: .init(label: "Fixed Rules", symbol: "list.bullet.rectangle", color: Theme.inkSoft),
                    items: [
                        .init(label: "Video 'For You' feed", symbol: "play.rectangle.fill", inA: true),
                        .init(label: "A calculator", symbol: "plus.forwardslash.minus", inA: false),
                        .init(label: "Face unlock", symbol: "faceid", inA: true),
                        .init(label: "A light switch", symbol: "lightbulb.fill", inA: false),
                        .init(label: "Voice assistant", symbol: "mic.fill", inA: true),
                        .init(label: "An alarm clock", symbol: "alarm.fill", inA: false),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "What does 'narrow AI' mean?",
                    options: ["AI that's good at one specific job", "AI smarter than any human", "AI that fits on a small screen"],
                    correctIndex: 0,
                    explanation: "Right — every AI you use today is narrow: brilliant at one task, clueless outside it.")),
                .reflect(ReflectPrompt(
                    prompt: "Which AI do you use most in real life?",
                    options: ["Video/music apps", "Maps", "Games", "Voice assistant"])),
            ]),

        // 2 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.2", tier: .explorers, bigIdea: .learning, order: 2,
            title: "Train It, Break It, Fix It",
            subtitle: "Data makes the AI",
            symbol: "brain.head.profile",
            screens: [
                .teach(TeachCard(
                    title: "AI Learns From Data",
                    body: "A model learns patterns from examples we give it — the 'training data'. Good data in, good results out.",
                    symbol: "cylinder.split.1x2.fill")),
                .teach(TeachCard(
                    title: "Garbage In, Garbage Out",
                    body: "If the examples are messy, unfair, or wrong, the AI learns the wrong thing. The data matters more than anything.",
                    symbol: "trash.fill")),
                .game(.sort(SortGame(
                    title: "Good Data or Bad Data?",
                    intro: "You're training an AI to recognize apples. Which examples help, and which will confuse it?",
                    binA: .init(label: "Helps It Learn", symbol: "checkmark.seal.fill", color: Theme.correct),
                    binB: .init(label: "Confuses It", symbol: "xmark.seal.fill", color: Theme.gentle),
                    items: [
                        .init(label: "Clear photo of a red apple", symbol: "photo.fill", inA: true),
                        .init(label: "A photo of a tomato labeled 'apple'", symbol: "exclamationmark.triangle.fill", inA: false),
                        .init(label: "Apples from many angles", symbol: "photo.stack.fill", inA: true),
                        .init(label: "A totally blurry picture", symbol: "camera.metering.none", inA: false),
                        .init(label: "Green AND red apples", symbol: "photo.on.rectangle", inA: true),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "An AI keeps calling tomatoes 'apples'. What's the most likely cause?",
                    options: ["It was trained on bad or mislabeled data", "It's tired", "Tomatoes are apples"],
                    correctIndex: 0,
                    explanation: "Exactly. Wrong labels in the training data teach the model the wrong pattern.")),
                .reflect(ReflectPrompt(
                    prompt: "Why do you think fair, varied data matters for AI?",
                    options: ["So it works for everyone", "So it's more accurate", "Both of these"])),
            ]),

        // 3 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.3", tier: .explorers, bigIdea: .reasoning, order: 3,
            title: "Inside the Guess",
            subtitle: "How a machine decides",
            symbol: "arrow.triangle.branch",
            screens: [
                .teach(TeachCard(
                    title: "Decisions as a Tree",
                    body: "One way AI decides is a 'decision tree' — a chain of questions where each answer narrows things down.",
                    symbol: "point.topleft.down.to.point.bottomright.curvepath.fill")),
                .game(.decisionTree(DecisionTreeGame(
                    intro: "Play the machine. Answer each question and reach a decision — just like an AI classifier would.",
                    goal: "Should this email go to Spam?",
                    root: .ask(
                        question: "Is the sender unknown?",
                        yes: .ask(question: "Does it ask for your password?",
                                  yes: .result("🚫 Spam — never reply!"),
                                  no: .ask(question: "Does it promise free money?",
                                           yes: .result("🚫 Probably spam"),
                                           no: .result("📥 Maybe okay — stay careful"))),
                        no: .result("📥 Inbox — it's from someone you know"))))),
                .quiz(QuizQuestion(
                    prompt: "How does a decision tree reach an answer?",
                    options: ["By following a path of yes/no questions", "By flipping a coin", "By asking a human every time"],
                    correctIndex: 0,
                    explanation: "Yes — each answer follows a branch until it lands on a decision.")),
                .reflect(ReflectPrompt(
                    prompt: "A spam filter sometimes blocks a real email by mistake. Is any AI perfect?",
                    options: ["No — all AI makes mistakes", "Yes, they're always right"])),
            ]),

        // 4 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.4", tier: .explorers, bigIdea: .interaction, order: 4,
            title: "Prompting 101",
            subtitle: "Ask well, get more",
            symbol: "bubble.left.and.bubble.right.fill",
            screens: [
                .teach(TeachCard(
                    title: "A Prompt Is Your Instruction",
                    body: "When you type to an AI, that's a prompt. The clearer and more specific it is, the better the answer.",
                    symbol: "text.cursor")),
                .teach(TeachCard(
                    title: "Add Detail & an Example",
                    body: "Say who it's for, how long, and give an example. 'Write a 4-line birthday poem for my little sister' beats 'write a poem'.",
                    symbol: "list.bullet.clipboard.fill")),
                .game(.promptImprover(PromptImproverGame(
                    intro: "Same goal, three different prompts. Pick the one that will get the best answer.",
                    task: "You want the AI to help you study for a science test on the water cycle.",
                    options: [
                        .init(text: "\"water\"", isBest: false,
                              result: "The AI dumps a giant, random article about water. Not helpful for studying."),
                        .init(text: "\"Quiz me with 5 easy questions about the water cycle, one at a time.\"", isBest: true,
                              result: "The AI asks you one clear question at a time — perfect for studying!"),
                        .init(text: "\"tell me science stuff\"", isBest: false,
                              result: "The AI has no idea what topic or format you want, so the answer is vague."),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "What makes a prompt better?",
                    options: ["Being clear and specific about what you want", "Using as few words as possible", "Typing in ALL CAPS"],
                    correctIndex: 0,
                    explanation: "Right. Specific asks — topic, format, length, audience — get you far better answers.")),
                .reflect(ReflectPrompt(
                    prompt: "The AI gives an answer that seems wrong. What's the smart move?",
                    options: ["Double-check it yourself", "Ask again more clearly", "Both"])),
            ]),

        // 5 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.5", tier: .explorers, bigIdea: .impact, order: 5,
            title: "Fair, Real, and Yours",
            subtitle: "Being a good AI citizen",
            symbol: "scale.3d",
            screens: [
                .teach(TeachCard(
                    title: "AI Can Be Biased",
                    body: "If training data is unfair, AI can be unfair too — working better for some people than others. Fair data helps.",
                    symbol: "scalemass.fill")),
                .teach(TeachCard(
                    title: "Is It Real?",
                    body: "AI can make fake photos, voices, and text that look real. Check the source before you believe or share.",
                    symbol: "eye.trianglebadge.exclamationmark.fill")),
                .teach(TeachCard(
                    title: "Give Credit",
                    body: "If AI helped you make something, it's honest to say so — at school and everywhere else.",
                    symbol: "hand.raised.fill")),
                .quiz(QuizQuestion(
                    prompt: "You see a shocking photo online that might be AI-made. First thing to do?",
                    options: ["Share it fast", "Check if it's real and where it came from", "Assume it's true"],
                    correctIndex: 1,
                    explanation: "Yes — pause and verify. AI fakes spread when people share before checking.")),
                .reflect(ReflectPrompt(
                    prompt: "What kind of AI user do you want to be?",
                    options: ["Curious", "Careful", "Honest", "All three"])),
            ]),
    ]
}
