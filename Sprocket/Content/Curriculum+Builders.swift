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
                    symbol: "person.crop.rectangle.badge.xmark.fill")),
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
    ]
}
