import SwiftUI

/// Builders track — ages 13–17. How AI actually works, prompt craft, and the
/// harder ethics: bias, deepfakes, privacy, academic honesty. Teen-level
/// framing — respect their judgment, give them the real mechanics, and treat
/// dangers as things to navigate, not just fear.
extension Curriculum {
    static let builders: [Unit] = [

        // 1 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.1", tier: .builders, bigIdea: .learning, order: 1,
            title: "How AI Actually Works",
            subtitle: "Models, training, inference",
            symbol: "cpu.fill",
            screens: [
                .teach(TeachCard(
                    title: "A Model Is a Pattern-Finder",
                    body: "Machine learning finds patterns in huge amounts of data and stores them as millions of adjustable numbers called parameters.",
                    symbol: "cpu.fill")),
                .teach(TeachCard(
                    title: "Training vs. Inference",
                    body: "Training = learning the patterns from data (slow, done once). Inference = using them to answer you (fast, every time you prompt).",
                    symbol: "arrow.triangle.2.circlepath")),
                .teach(TeachCard(
                    title: "Rules vs. Learning vs. Generative",
                    body: "Rule-based AI follows code a human wrote. Machine learning learns from data. Generative AI (like chatbots) creates new text, images, or audio.",
                    symbol: "square.stack.3d.up.fill")),
                .quiz(QuizQuestion(
                    prompt: "What's the difference between training and inference?",
                    options: [
                        "Training learns patterns from data; inference uses them to respond",
                        "They're two words for the same thing",
                        "Inference happens before training"],
                    correctIndex: 0,
                    explanation: "Correct. A model is trained once on data, then runs inference every time you use it.")),
                .reflect(ReflectPrompt(
                    prompt: "Which surprised you most?",
                    options: ["It's just patterns & numbers", "Training is separate from using it", "There are different kinds of AI"])),
            ]),

        // 2 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.2", tier: .builders, bigIdea: .reasoning, order: 2,
            title: "Inside a Language Model",
            subtitle: "Why chatbots do what they do",
            symbol: "text.word.spacing",
            screens: [
                .teach(TeachCard(
                    title: "It Predicts the Next Word",
                    body: "A large language model works by predicting the most likely next word, over and over. That's it — no lookup of 'the truth', just very good pattern prediction.",
                    symbol: "text.word.spacing")),
                .teach(TeachCard(
                    title: "Why It 'Hallucinates'",
                    body: "Because it predicts plausible text — not verified facts — it can state wrong things confidently. That's called a hallucination.",
                    symbol: "exclamationmark.bubble.fill")),
                .teach(TeachCard(
                    title: "Context Window",
                    body: "A model can only 'see' a limited amount of text at once — its context window. Beyond that, it forgets earlier parts of the conversation.",
                    symbol: "rectangle.dashed")),
                .game(.nextWord(NextWordGame(
                    intro: "Predict the model, not the truth. Pick the word it would give the highest probability.",
                    rounds: [
                        .init(context: "Once upon a ___",
                              options: [.init(word: "time", probability: 0.91),
                                        .init(word: "dragon", probability: 0.04),
                                        .init(word: "star", probability: 0.03),
                                        .init(word: "midnight", probability: 0.02)],
                              insight: "Near-certainty. High probability, almost no information — the model is completing a fossilised phrase."),
                        .init(context: "According to a 2021 study by Dr. ___",
                              options: [.init(word: "Smith", probability: 0.34),
                                        .init(word: "Johnson", probability: 0.27),
                                        .init(word: "Chen", probability: 0.22),
                                        .init(word: "Aeliana", probability: 0.17)],
                              insight: "None of these people wrote that study — there is no study. The model is fluently inventing a plausible name. This is precisely how fake citations are born."),
                        .init(context: "2 + 2 = ___",
                              options: [.init(word: "4", probability: 0.96),
                                        .init(word: "5", probability: 0.02),
                                        .init(word: "22", probability: 0.01),
                                        .init(word: "four", probability: 0.01)],
                              insight: "It answers correctly — but it isn't calculating. It's predicting the token that nearly always follows. On harder arithmetic, that distinction starts to bite."),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "A chatbot confidently gives you a fake book citation. Why?",
                    options: [
                        "It predicts plausible-looking text, not verified facts",
                        "It's lying on purpose",
                        "The book was deleted"],
                    correctIndex: 0,
                    explanation: "Right. It generates what *looks* right. Always verify facts, names, and citations.")),
                .reflect(ReflectPrompt(
                    prompt: "How will this change how you use chatbots?",
                    options: ["I'll verify important facts", "I'll trust it less blindly", "Both"])),
            ]),

        // 3 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.3", tier: .builders, bigIdea: .interaction, order: 3,
            title: "The Craft of Prompting",
            subtitle: "Role, context, constraints",
            symbol: "wand.and.stars",
            screens: [
                .teach(TeachCard(
                    title: "Great Prompts Have Structure",
                    body: "Set a role ('act as a tutor'), give context, state constraints (length, tone, format), and add an example. Then iterate.",
                    symbol: "slider.horizontal.3")),
                .game(.promptImprover(PromptImproverGame(
                    intro: "You're prepping for a history essay. Which prompt gets the most useful response?",
                    task: "Get help planning an essay on the causes of World War I.",
                    options: [
                        .init(text: "\"ww1 causes\"", isBest: false,
                              result: "A generic wall of text. No structure, no help with *your* essay."),
                        .init(text: "\"Act as a history tutor. Give me 4 main causes of WWI, each with one example, as a bulleted outline I can build an essay from.\"", isBest: true,
                              result: "A clean, structured outline with roles, constraints, and format — exactly what you can build from."),
                        .init(text: "\"write my essay for me\"", isBest: false,
                              result: "Even if it answers, handing in AI-written work is dishonest — and you learn nothing."),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "Which is part of a well-structured prompt?",
                    options: ["Role, context, constraints, and an example", "Only a single keyword", "Threatening the AI"],
                    correctIndex: 0,
                    explanation: "Yes. Structure and specificity — plus iterating on the result — are the whole craft.")),
                .reflect(ReflectPrompt(
                    prompt: "Where's the line between AI *helping* you and doing your work?",
                    options: ["Helping = it supports my thinking", "Doing = it replaces my thinking", "I'll keep that line in mind"])),
            ]),

        // 4 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.4", tier: .builders, bigIdea: .learning, order: 4,
            title: "Bias, Fairness & Data",
            subtitle: "Where harm comes from",
            symbol: "scalemass.fill",
            screens: [
                .teach(TeachCard(
                    title: "Bias Comes From Data",
                    body: "If a hiring AI trained mostly on one group's résumés, it can unfairly favor them. The model reflects the data — including its unfairness.",
                    symbol: "scalemass.fill")),
                .teach(TeachCard(
                    title: "Your Data Footprint",
                    body: "Much AI is trained on data scraped from the internet — possibly including things you posted. What you share can outlive the moment.",
                    symbol: "shoeprints.fill")),
                .game(.trainAndTest(TrainAndTestGame(
                    intro: "You choose the training set. Then the model meets people it has never seen.",
                    goal: "Train a model to recognise \"a doctor\"",
                    pool: [
                        .init(label: "Doctors of many genders", symbol: "person.2.fill", isGood: true,
                              why: "Representative of who doctors actually are."),
                        .init(label: "Doctors with a range of skin tones", symbol: "person.3.fill", isGood: true,
                              why: "Stops the model working well for some people and poorly for others."),
                        .init(label: "Doctors in clinics, labs and the field", symbol: "cross.case.fill", isGood: true,
                              why: "Varied context, so it doesn't just learn \"white coat\"."),
                        .init(label: "Only middle-aged men in white coats", symbol: "person.fill", isGood: false,
                              why: "Narrow. The model learns \"doctor = man in a coat\" and fails on everyone else."),
                        .init(label: "All images from one stock-photo site", symbol: "photo.stack.fill", isGood: false,
                              why: "A single source bakes that source's blind spots straight into the model."),
                        .init(label: "Images scraped without consent", symbol: "exclamationmark.shield.fill", isGood: false,
                              why: "Ethically fraught — and scraped sets are usually skewed as well."),
                    ],
                    pickCount: 3,
                    tests: [
                        .init(label: "A female surgeon", symbol: "person.fill"),
                        .init(label: "A doctor in scrubs, no coat", symbol: "tshirt.fill"),
                        .init(label: "A doctor with dark skin", symbol: "person.fill.checkmark"),
                        .init(label: "A doctor in a rural clinic", symbol: "cross.case.fill"),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "An AI résumé screener favors one group. Most likely root cause?",
                    options: ["Biased or unrepresentative training data", "A bug in the screen brightness", "Too many résumés"],
                    correctIndex: 0,
                    explanation: "Correct. Biased data produces biased models — which is why data fairness and audits matter.")),
                .reflect(ReflectPrompt(
                    prompt: "Should companies be allowed to use AI for big decisions (jobs, loans) with no human check?",
                    options: ["No — needs human oversight", "Only if it's audited for fairness", "I'm still thinking about it"])),
            ]),

        // 5 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.5", tier: .builders, bigIdea: .impact, order: 5,
            title: "Deepfakes & Misinformation",
            subtitle: "Seeing clearly online",
            symbol: "eye.trianglebadge.exclamationmark.fill",
            screens: [
                .teach(TeachCard(
                    title: "Synthetic Media Is Convincing",
                    body: "AI can clone voices and faces. Deepfakes have fooled millions — the tech is good enough that 'I saw it' is no longer proof.",
                    symbol: "person.crop.circle.badge.exclamationmark.fill")),
                .teach(TeachCard(
                    title: "Verify Before You Trust",
                    body: "Check the source, look for other outlets reporting it, and be extra skeptical of content that makes you very angry — that's often the point.",
                    symbol: "checkmark.shield.fill")),
                .quiz(QuizQuestion(
                    prompt: "Best defense against deepfakes and misinformation?",
                    options: ["Verify the source before believing or sharing", "Never use the internet", "Only trust videos"],
                    correctIndex: 0,
                    explanation: "Right. Source-checking and healthy skepticism beat any single 'detector'.")),
                .reflect(ReflectPrompt(
                    prompt: "Have you seen something online you now suspect was AI-made?",
                    options: ["Yes, probably", "Not sure", "I'll look more carefully now"])),
            ]),

        // 6 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.6", tier: .builders, bigIdea: .impact, order: 6,
            title: "Using AI Responsibly",
            subtitle: "Your own code of ethics",
            symbol: "checkmark.seal.fill",
            screens: [
                .teach(TeachCard(
                    title: "Honesty & Disclosure",
                    body: "Using AI to learn is great. Passing off AI work as your own is cheating. When in doubt, disclose how you used it.",
                    symbol: "hand.raised.fill")),
                .teach(TeachCard(
                    title: "Don't Over-Rely",
                    body: "If AI does all your thinking, your own skills fade. Use it as a coach and a tool — not a replacement for your judgment.",
                    symbol: "figure.mind.and.body")),
                .teach(TeachCard(
                    title: "AI & People",
                    body: "AI will change many jobs and how we live. It's a tool built by people, guided by choices — including yours.",
                    symbol: "person.3.fill")),
                .reflect(ReflectPrompt(
                    prompt: "Write your own rule: I promise to always ___ when I use AI.",
                    options: ["Check important facts", "Give credit when it helps me", "Keep thinking for myself", "Stay kind and safe"])),
            ]),

        // 7 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.7", tier: .builders, bigIdea: .learning, order: 7,
            title: "Where Training Data Comes From",
            subtitle: "Scraping, consent & credit",
            symbol: "tray.full.fill",
            screens: [
                .teach(TeachCard(
                    title: "The Internet as a Textbook",
                    body: "Many large models are trained on enormous amounts of text, images, and code scraped from the public web — books, art, forum posts, photos.",
                    symbol: "globe")),
                .teach(TeachCard(
                    title: "Consent & Credit",
                    body: "Most creators were never asked, and aren't paid or credited. Whether that's fair use or exploitation is being fought over in courts right now.",
                    symbol: "signature")),
                .teach(TeachCard(
                    title: "Your Data, Too",
                    body: "Things you post publicly can end up as training data. It's worth deciding, deliberately, what you put into the world.",
                    symbol: "shoeprints.fill")),
                .quiz(QuizQuestion(
                    prompt: "Why is web-scraped training data controversial?",
                    options: [
                        "Creators often didn't consent and aren't credited or paid",
                        "The internet is too small to train on",
                        "Scraped data is always factually wrong"],
                    correctIndex: 0,
                    explanation: "Right — it's a live legal and ethical question, not a settled one.")),
                .reflect(ReflectPrompt(
                    prompt: "Should creators be paid when their work trains a model?",
                    options: ["Yes, always", "Only with consent", "It's genuinely complicated"])),
            ]),

        // 8 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.8", tier: .builders, bigIdea: .interaction, order: 8,
            title: "Guardrails & Jailbreaks",
            subtitle: "Why models say no",
            symbol: "shield.lefthalf.filled",
            screens: [
                .teach(TeachCard(
                    title: "Models Have Limits — On Purpose",
                    body: "Guardrails stop a model producing genuinely harmful output: weapons instructions, self-harm content, someone's private data.",
                    symbol: "shield.lefthalf.filled")),
                .teach(TeachCard(
                    title: "\"Jailbreaking\" Isn't Clever",
                    body: "Tricking a model past its guardrails usually breaks the terms you agreed to — and the harm it can produce is real, not hypothetical.",
                    symbol: "lock.trianglebadge.exclamationmark.fill")),
                .teach(TeachCard(
                    title: "Guardrails Are Imperfect",
                    body: "They can also be too cautious, refusing harmless things. Good systems get corrected over time — by people reporting both failures.",
                    symbol: "slider.horizontal.3")),
                .quiz(QuizQuestion(
                    prompt: "Why do AI systems refuse certain requests?",
                    options: [
                        "Guardrails exist to reduce real-world harm",
                        "To be deliberately annoying",
                        "The model ran out of words"],
                    correctIndex: 0,
                    explanation: "Correct. They're a safety design choice — imperfect, but there for a reason.")),
                .reflect(ReflectPrompt(
                    prompt: "Where should the line sit on what an AI will do?",
                    options: ["Err toward safety", "Depends on the context", "I'm still working it out"])),
            ]),

        // 9 ──────────────────────────────────────────────────────────────
        Unit(
            id: "builders.9", tier: .builders, bigIdea: .impact, order: 9,
            title: "Verify Like a Journalist",
            subtitle: "Source-checking as a habit",
            symbol: "magnifyingglass",
            screens: [
                .teach(TeachCard(
                    title: "The Reporter's Reflex",
                    body: "Three questions, every time: Who said it? When? Can anyone independent confirm it? Content engineered to enrage you deserves the most scrutiny.",
                    symbol: "magnifyingglass")),
                .game(.decisionTree(DecisionTreeGame(
                    intro: "Walk a claim through a real verification process and see where it lands.",
                    goal: "Should you trust this claim?",
                    root: .ask(
                        question: "Can you find the original source?",
                        yes: .ask(question: "Do independent outlets report it too?",
                                  yes: .result("✅ Likely reliable — stay curious anyway"),
                                  no: .result("❓ Single source — treat with caution")),
                        no: .ask(question: "Is it designed to make you angry?",
                                 yes: .result("🚩 Likely manipulation — don't share"),
                                 no: .result("❓ Unverified — hold off on sharing")))))),
                .quiz(QuizQuestion(
                    prompt: "What's the strongest signal a claim is reliable?",
                    options: [
                        "Independent corroboration from multiple sources",
                        "It has a lot of likes and shares",
                        "It confirms what you already believe"],
                    correctIndex: 0,
                    explanation: "Yes. Popularity isn't evidence, and agreement with your priors is the weakest test of all.")),
                .reflect(ReflectPrompt(
                    prompt: "Which part of verifying is hardest for you?",
                    options: ["Slowing down", "Finding the source", "Resisting outrage"])),
            ]),

        // 10 ─────────────────────────────────────────────────────────────
        Unit(
            id: "builders.10", tier: .builders, bigIdea: .impact, order: 10,
            title: "AI and Your Future",
            subtitle: "Agency, work & choice",
            symbol: "figure.stand",
            screens: [
                .teach(TeachCard(
                    title: "Tools Change Work, Not Worth",
                    body: "AI will reshape a lot of jobs. The skills that hold their value are judgment, creativity, and knowing which questions are worth asking.",
                    symbol: "briefcase.fill")),
                .teach(TeachCard(
                    title: "Be the Person in the Loop",
                    body: "The most valuable role is rarely 'does the task' — it's 'decides whether the output is any good'. That's a skill you can practise now.",
                    symbol: "person.fill.checkmark")),
                .teach(TeachCard(
                    title: "You Have Agency",
                    body: "AI is built by people making choices about data, guardrails, and who it serves. You could be one of those people.",
                    symbol: "person.3.fill")),
                .quiz(QuizQuestion(
                    prompt: "Which skill stays most valuable alongside capable AI?",
                    options: [
                        "Judgment — knowing what's good and what to ask",
                        "Typing quickly",
                        "Memorising facts"],
                    correctIndex: 0,
                    explanation: "Right. AI can generate; deciding what's worth generating — and whether it's any good — is the human job.")),
                .reflect(ReflectPrompt(
                    prompt: "You finished the Builders track. What will you do with this?",
                    options: ["Use AI thoughtfully", "Help others understand it", "Build something", "All of it"])),
            ]),
    ]
}
