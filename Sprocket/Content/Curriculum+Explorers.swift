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
                .game(.trainAndTest(TrainAndTestGame(
                    intro: "Choose what to train on, then watch it be tested on pictures it has never seen.",
                    goal: "Train a model to recognise apples",
                    pool: [
                        .init(label: "Clear photo of a red apple", symbol: "photo.fill", isGood: true,
                              why: "Clean, well-lit and correctly labelled."),
                        .init(label: "Photo of a green apple", symbol: "leaf.fill", isGood: true,
                              why: "Adds variety, so it doesn't decide apples are only red."),
                        .init(label: "An apple on a branch, far away", symbol: "photo.on.rectangle.angled", isGood: true,
                              why: "A different angle and background helps it generalise."),
                        .init(label: "A tomato labelled \"apple\"", symbol: "exclamationmark.triangle.fill", isGood: false,
                              why: "Mislabelled — this actively teaches the model the wrong thing."),
                        .init(label: "A very blurry photo", symbol: "camera.metering.none", isGood: false,
                              why: "Too noisy to learn anything useful from."),
                        .init(label: "The same red apple, 50 times", symbol: "square.stack.3d.up.fill", isGood: false,
                              why: "No variety — it memorises one apple instead of learning \"apple\"."),
                    ],
                    pickCount: 4,
                    tests: [
                        .init(label: "A green apple", symbol: "leaf.fill"),
                        .init(label: "An apple in shadow", symbol: "moon.fill"),
                        .init(label: "An apple on a branch", symbol: "photo.on.rectangle.angled"),
                        .init(label: "A tomato (not an apple!)", symbol: "exclamationmark.triangle.fill"),
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

        // 6 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.6", tier: .explorers, bigIdea: .perception, order: 6,
            title: "AI in Your Day",
            subtitle: "Spotting it in the wild",
            symbol: "clock.fill",
            screens: [
                .teach(TeachCard(
                    title: "From Wake-Up to Bedtime",
                    body: "AI picks your video recommendations, filters spam, fixes your typos, and suggests the next song. Most of it is invisible.",
                    symbol: "clock.fill")),
                .teach(TeachCard(
                    title: "The Tell: Does It Learn?",
                    body: "A calculator always does the same thing. An AI gets better as it sees more data. That's the difference.",
                    symbol: "chart.line.uptrend.xyaxis")),
                .game(.sort(SortGame(
                    title: "Learns, or Just Follows Rules?",
                    intro: "Sort each tool: does it learn from data, or just follow steps a human wrote?",
                    binA: .init(label: "Learns From Data", symbol: "brain.head.profile", color: Theme.explorers),
                    binB: .init(label: "Fixed Steps", symbol: "list.bullet.rectangle", color: Theme.inkSoft),
                    items: [
                        .init(label: "Autocorrect suggestions", symbol: "keyboard", inA: true),
                        .init(label: "A stopwatch", symbol: "stopwatch.fill", inA: false),
                        .init(label: "Music recommendations", symbol: "music.note", inA: true),
                        .init(label: "A calendar reminder", symbol: "calendar", inA: false),
                        .init(label: "Spam filter", symbol: "envelope.fill", inA: true),
                        .init(label: "A volume slider", symbol: "speaker.wave.2.fill", inA: false),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "What's the clearest sign that something uses AI?",
                    options: ["It improves as it sees more data", "It has a screen", "It needs electricity"],
                    correctIndex: 0,
                    explanation: "Exactly. Learning from data is the defining trait — not screens or power.")),
                .reflect(ReflectPrompt(
                    prompt: "Which everyday AI surprised you most?",
                    options: ["Autocorrect", "Recommendations", "Spam filters", "All of them"])),
            ]),

        // 7 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.7", tier: .explorers, bigIdea: .reasoning, order: 7,
            title: "How Chatbots Guess",
            subtitle: "Predicting the next word",
            symbol: "text.word.spacing",
            screens: [
                .teach(TeachCard(
                    title: "It Predicts What Comes Next",
                    body: "A chatbot writes by guessing the most likely next word — then the next, then the next. That's really all it does.",
                    symbol: "text.word.spacing")),
                .teach(TeachCard(
                    title: "\"Sounds Right\" Isn't \"Is Right\"",
                    body: "It predicts what sounds correct, not what's actually true. That's why it can be confidently wrong.",
                    symbol: "exclamationmark.bubble.fill")),
                .game(.nextWord(NextWordGame(
                    intro: "You're the model now. Guess which word the AI would pick — not what's true, but what's most likely.",
                    rounds: [
                        .init(context: "The cat sat on the ___",
                              options: [.init(word: "mat", probability: 0.58),
                                        .init(word: "chair", probability: 0.24),
                                        .init(word: "sandwich", probability: 0.12),
                                        .init(word: "moon", probability: 0.06)],
                              insight: "\"Mat\" wins because those words sit together constantly in the text the model learned from."),
                        .init(context: "Peanut butter and ___",
                              options: [.init(word: "jelly", probability: 0.74),
                                        .init(word: "jam", probability: 0.16),
                                        .init(word: "science", probability: 0.06),
                                        .init(word: "socks", probability: 0.04)],
                              insight: "It has seen this phrase a staggering number of times. Very likely — but likely isn't the same as right."),
                        .init(context: "The capital of Australia is ___",
                              options: [.init(word: "Sydney", probability: 0.46),
                                        .init(word: "Canberra", probability: 0.38),
                                        .init(word: "Melbourne", probability: 0.12),
                                        .init(word: "Perth", probability: 0.04)],
                              insight: "Look closely: the model leans toward \"Sydney\" because it appears far more often — but the real capital is Canberra. This is exactly how a chatbot ends up confidently wrong."),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "A chatbot states a 'fact' that turns out to be false. Why?",
                    options: [
                        "It predicts likely-sounding words, not verified facts",
                        "Somebody typed the wrong answer in",
                        "It is broken and needs restarting"],
                    correctIndex: 0,
                    explanation: "Right. It's a prediction machine, not a truth machine. Always verify.")),
                .reflect(ReflectPrompt(
                    prompt: "What will you do before trusting a chatbot's fact?",
                    options: ["Check another source", "Ask an adult", "Both"])),
            ]),

        // 8 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.8", tier: .explorers, bigIdea: .learning, order: 8,
            title: "Learning by Playing",
            subtitle: "Rewards teach machines",
            symbol: "gamecontroller.fill",
            screens: [
                .teach(TeachCard(
                    title: "Trial, Error, Reward",
                    body: "Some AI learns like you learn a game: try something, see the score, keep what worked. Good moves earn a reward.",
                    symbol: "gamecontroller.fill")),
                .teach(TeachCard(
                    title: "Millions of Tries",
                    body: "A game-playing AI can practice millions of matches in a day. You can't — but you learn far faster from just a few.",
                    symbol: "infinity")),
                .game(.sort(SortGame(
                    title: "Reward the Robot",
                    intro: "You're training a soccer robot. Which moves should earn a reward?",
                    binA: .init(label: "Good Move", symbol: "hand.thumbsup.fill", color: Theme.correct),
                    binB: .init(label: "Bad Move", symbol: "hand.thumbsdown.fill", color: Theme.gentle),
                    items: [
                        .init(label: "Scores a goal", symbol: "soccerball", inA: true),
                        .init(label: "Kicks it out of bounds", symbol: "arrow.up.right", inA: false),
                        .init(label: "Passes to a teammate", symbol: "person.2.fill", inA: true),
                        .init(label: "Trips another player", symbol: "figure.fall", inA: false),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "How does a game-playing AI get good?",
                    options: [
                        "It practices and is rewarded for good moves",
                        "It reads the rulebook once",
                        "It copies a human exactly"],
                    correctIndex: 0,
                    explanation: "Yes — reward and repetition. It's called reinforcement learning.")),
                .reflect(ReflectPrompt(
                    prompt: "Is practising millions of times an unfair advantage?",
                    options: ["It's different, not unfair", "Yes, it's an advantage", "I'm not sure"])),
            ]),

        // 9 ──────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.9", tier: .explorers, bigIdea: .impact, order: 9,
            title: "Spot the Fake",
            subtitle: "AI-made images",
            symbol: "eye.trianglebadge.exclamationmark.fill",
            screens: [
                .teach(TeachCard(
                    title: "AI Can Invent Pictures",
                    body: "AI can generate photos of things that never happened, of people who don't exist. They can look very real.",
                    symbol: "photo.stack.fill")),
                .teach(TeachCard(
                    title: "Clues to Look For",
                    body: "Odd hands and fingers, garbled text on signs, backgrounds that melt together. But the best check is always: where did it come from?",
                    symbol: "magnifyingglass")),
                .game(.sort(SortGame(
                    title: "Clue, or Not a Clue?",
                    intro: "Which of these actually hint that an image might be AI-made?",
                    binA: .init(label: "Might Be AI", symbol: "sparkles", color: Theme.spark),
                    binB: .init(label: "Not a Clue", symbol: "minus.circle", color: Theme.inkSoft),
                    items: [
                        .init(label: "Six fingers on a hand", symbol: "hand.raised.fill", inA: true),
                        .init(label: "The photo is in colour", symbol: "paintpalette.fill", inA: false),
                        .init(label: "Gibberish text on a sign", symbol: "textformat", inA: true),
                        .init(label: "A friend shared it", symbol: "person.2.fill", inA: false),
                        .init(label: "The background melts together", symbol: "scribble", inA: true),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "Best first move when a shocking image appears in your feed?",
                    options: ["Check where it came from", "Share it before it disappears", "Assume everything is fake"],
                    correctIndex: 0,
                    explanation: "Yes. Source-checking beats both gullibility and blanket cynicism.")),
                .reflect(ReflectPrompt(
                    prompt: "Have you seen an image you now suspect was AI-made?",
                    options: ["Yes, probably", "Not sure", "I'll look more carefully now"])),
            ]),

        // 10 ─────────────────────────────────────────────────────────────
        Unit(
            id: "explorers.10", tier: .explorers, bigIdea: .interaction, order: 10,
            title: "Try, Tweak, Repeat",
            subtitle: "Prompting is a conversation",
            symbol: "arrow.triangle.2.circlepath",
            screens: [
                .teach(TeachCard(
                    title: "The First Try Is Rarely the Best",
                    body: "Good prompting is a loop: ask, read the answer, then refine. Experts don't write perfect prompts — they iterate.",
                    symbol: "arrow.triangle.2.circlepath")),
                .game(.promptImprover(PromptImproverGame(
                    intro: "Same goal, three prompts. Which one gets you what you actually want?",
                    task: "You want a short, funny poem about your cat Mochi for a birthday card.",
                    options: [
                        .init(text: "\"poem\"", isBest: false,
                              result: "A long, serious poem about nothing in particular. Not about Mochi at all."),
                        .init(text: "\"Write a funny 4-line poem about my cat Mochi for a birthday card. Keep it kid-friendly.\"", isBest: true,
                              result: "A short, silly, 4-line poem about Mochi that fits perfectly on a card."),
                        .init(text: "\"make it funnier\"", isBest: false,
                              result: "The AI has no idea what \"it\" refers to — there's no context yet."),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "The answer isn't what you wanted. What's the best next move?",
                    options: ["Refine your prompt and try again", "Give up", "Repeat the same prompt louder"],
                    correctIndex: 0,
                    explanation: "Exactly. Add detail, give an example, say what was wrong — then ask again.")),
                .reflect(ReflectPrompt(
                    prompt: "You finished the Explorers track! What's next?",
                    options: ["Try the Builders track", "Teach someone else", "Keep practising prompts"])),
            ]),
    ]
}
