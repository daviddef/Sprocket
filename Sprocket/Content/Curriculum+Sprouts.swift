import SwiftUI

/// Sprouts track — ages 5–8. Play-first, pre-reader friendly: short
/// sentences, one idea per card, every screen narratable. Ethics ("AI can be
/// wrong, check with a grown-up", "be kind") is woven in from unit 1, not
/// saved for a scary finale. Six units, one per Big Idea (with an intro unit
/// folded under Perception).
extension Curriculum {
    static let sprouts: [Unit] = [

        // 1 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.1", tier: .sprouts, bigIdea: .perception, order: 1,
            title: "Robot or Not?",
            subtitle: "What is AI?",
            symbol: "sparkles",
            screens: [
                .teach(TeachCard(
                    title: "Hi! I'm Sprocket.",
                    body: "I'm a friendly robot. I run on something called AI. Let's learn what that means together!",
                    symbol: "face.smiling",
                    narration: "Hi! I'm Sprocket. I'm a friendly robot. I run on something called A.I. Let's learn what that means together!")),
                .teach(TeachCard(
                    title: "What is AI?",
                    body: "AI is a clever computer. It can guess, sort, and learn — a little like you do!",
                    symbol: "brain.head.profile",
                    narration: "A.I. is a clever computer. It can guess, sort, and learn, a little like you do!")),
                .game(.sort(SortGame(
                    title: "Robot or Not?",
                    intro: "Some things use a smart computer. Some are just everyday things. Can you sort them?",
                    binA: .init(label: "Smart Computer", symbol: "cpu", color: Theme.explorers),
                    binB: .init(label: "Just a Thing", symbol: "cube.box", color: Theme.inkSoft),
                    items: [
                        .init(label: "Smart speaker", symbol: "hifispeaker.fill", inA: true),
                        .init(label: "A rock", symbol: "mountain.2.fill", inA: false),
                        .init(label: "Self-driving car", symbol: "car.fill", inA: true),
                        .init(label: "A spoon", symbol: "fork.knife", inA: false),
                        .init(label: "Phone that answers you", symbol: "iphone", inA: true),
                        .init(label: "Teddy bear", symbol: "teddybear.fill", inA: false),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "Which one uses AI?",
                    options: ["A wooden chair", "A speaker that answers your questions", "A paper cup"],
                    correctIndex: 1,
                    explanation: "Yes! A speaker that listens and answers uses AI. A chair and a cup just sit there.",
                    narration: "Which one uses A.I.?")),
                .reflect(ReflectPrompt(
                    prompt: "How do you feel about meeting AI?",
                    options: ["Excited!", "Curious", "A little unsure"],
                    narration: "How do you feel about meeting A.I.? There's no wrong answer.")),
            ]),

        // 2 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.2", tier: .sprouts, bigIdea: .perception, order: 2,
            title: "Teach the Puppy to See",
            subtitle: "Computers can sense",
            symbol: "eye.fill",
            screens: [
                .teach(TeachCard(
                    title: "Computers Can 'See'",
                    body: "With a camera, a computer can look at a picture. But first, we have to teach it what things are.",
                    symbol: "camera.fill",
                    narration: "With a camera, a computer can look at a picture. But first, we have to teach it what things are.")),
                .teach(TeachCard(
                    title: "We Teach by Showing",
                    body: "To teach an AI puppy a cat from a dog, we show it lots of cats and lots of dogs. That's called examples.",
                    symbol: "photo.on.rectangle.angled",
                    narration: "To teach an A.I. puppy a cat from a dog, we show it lots of cats and lots of dogs. That's called examples.")),
                .game(.sort(SortGame(
                    title: "Show the Examples",
                    intro: "Help teach the puppy! Sort each picture so it learns cats from dogs.",
                    binA: .init(label: "Cat", symbol: "cat.fill", color: Theme.sprouts),
                    binB: .init(label: "Dog", symbol: "dog.fill", color: Theme.explorers),
                    items: [
                        .init(label: "Meow!", symbol: "cat.fill", inA: true),
                        .init(label: "Woof!", symbol: "dog.fill", inA: false),
                        .init(label: "Purr", symbol: "cat.fill", inA: true),
                        .init(label: "Fetch!", symbol: "dog.fill", inA: false),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "How does an AI learn what a cat looks like?",
                    options: ["It just knows by magic", "We show it lots of cat pictures", "It reads a book"],
                    correctIndex: 1,
                    explanation: "Right! We show it many examples. The more good examples, the better it learns.",
                    narration: "How does an A.I. learn what a cat looks like?")),
                .reflect(ReflectPrompt(
                    prompt: "If we only showed the puppy cats, could it learn dogs?",
                    options: ["No — it needs dog examples too", "Yes, easily"],
                    narration: "If we only showed the puppy cats, could it learn dogs?")),
            ]),

        // 3 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.3", tier: .sprouts, bigIdea: .reasoning, order: 3,
            title: "The Yes/No Treasure Map",
            subtitle: "Thinking in steps",
            symbol: "arrow.triangle.branch",
            screens: [
                .teach(TeachCard(
                    title: "AI Thinks in Steps",
                    body: "A computer can guess things by asking yes-or-no questions, one at a time, like a treasure map.",
                    symbol: "map.fill",
                    narration: "A computer can guess things by asking yes or no questions, one at a time, like a treasure map.")),
                .game(.decisionTree(DecisionTreeGame(
                    intro: "Think of an animal. Answer yes or no, and watch the computer guess it!",
                    goal: "Let's guess your animal",
                    root: .ask(
                        question: "Does it live in the water?",
                        yes: .ask(question: "Is it very big?",
                                  yes: .result("Is it a whale? 🐳"),
                                  no: .result("Is it a fish? 🐟")),
                        no: .ask(question: "Can it fly?",
                                 yes: .result("Is it a bird? 🐦"),
                                 no: .result("Is it a dog? 🐕")))))),
                .quiz(QuizQuestion(
                    prompt: "How did the computer make its guess?",
                    options: ["It asked yes/no questions step by step", "It guessed randomly", "It asked a friend"],
                    correctIndex: 0,
                    explanation: "Exactly! Step by step, each answer helped it get closer.",
                    narration: "How did the computer make its guess?")),
                .reflect(ReflectPrompt(
                    prompt: "Did the computer guess your animal?",
                    options: ["Yes!", "No, it was tricky"],
                    narration: "Did the computer guess your animal?")),
            ]),

        // 4 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.4", tier: .sprouts, bigIdea: .learning, order: 4,
            title: "Good Job, Robot!",
            subtitle: "Learning from examples",
            symbol: "hand.thumbsup.fill",
            screens: [
                .teach(TeachCard(
                    title: "AI Gets Better",
                    body: "When AI does something right, we say 'good job!' When it's wrong, we help it fix it. That's how it learns.",
                    symbol: "arrow.up.heart.fill",
                    narration: "When A.I. does something right, we say good job! When it's wrong, we help it fix it. That's how it learns.")),
                .teach(TeachCard(
                    title: "Practice Makes Better",
                    body: "Just like you get better at drawing or soccer, AI gets better with lots of practice.",
                    symbol: "figure.run",
                    narration: "Just like you get better at drawing or soccer, A.I. gets better with lots of practice.")),
                .quiz(QuizQuestion(
                    prompt: "How does AI get better at something?",
                    options: ["It practices with lots of examples", "It takes a nap", "It never changes"],
                    correctIndex: 0,
                    explanation: "Yes! More practice and feedback help it improve — just like you.",
                    narration: "How does A.I. get better at something?")),
                .reflect(ReflectPrompt(
                    prompt: "What are YOU getting better at with practice?",
                    options: ["Reading", "Sports", "Drawing", "Something else"],
                    narration: "What are you getting better at with practice?")),
            ]),

        // 5 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.5", tier: .sprouts, bigIdea: .interaction, order: 5,
            title: "Ask the Buddy",
            subtitle: "Talking with AI",
            symbol: "bubble.left.and.bubble.right.fill",
            screens: [
                .teach(TeachCard(
                    title: "We Can Talk to AI",
                    body: "Some AI can answer questions when we ask. What we ask is called a prompt.",
                    symbol: "text.bubble.fill",
                    narration: "Some A.I. can answer questions when we ask. What we ask is called a prompt.")),
                .teach(TeachCard(
                    title: "Clear Asking Helps",
                    body: "If you ask clearly, you get a better answer. 'Tell me about dogs' works better than just 'dogs'.",
                    symbol: "checkmark.bubble.fill",
                    narration: "If you ask clearly, you get a better answer. Tell me about dogs works better than just dogs.")),
                .quiz(QuizQuestion(
                    prompt: "Which is a clearer thing to ask?",
                    options: ["\"Dog.\"", "\"Can you tell me what dogs like to eat?\"", "\"Umm...\""],
                    correctIndex: 1,
                    explanation: "Great! A full, clear question helps the AI understand what you want.",
                    narration: "Which is a clearer thing to ask?")),
                .teach(TeachCard(
                    title: "AI Isn't a Person",
                    body: "The buddy is a helper, not a real friend with feelings. And sometimes it can be wrong!",
                    symbol: "exclamationmark.bubble.fill",
                    narration: "The buddy is a helper, not a real friend with feelings. And sometimes it can be wrong!")),
                .reflect(ReflectPrompt(
                    prompt: "If AI tells you something surprising, what should you do?",
                    options: ["Check with a grown-up", "Believe it right away"],
                    narration: "If A.I. tells you something surprising, what should you do?")),
            ]),

        // 6 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.6", tier: .sprouts, bigIdea: .impact, order: 6,
            title: "Kind & Careful",
            subtitle: "Good, bad & being fair",
            symbol: "heart.fill",
            screens: [
                .teach(TeachCard(
                    title: "AI Can Make Mistakes",
                    body: "AI is helpful, but it isn't perfect. It can be wrong, so we always check important things.",
                    symbol: "questionmark.circle.fill",
                    narration: "A.I. is helpful, but it isn't perfect. It can be wrong, so we always check important things.")),
                .teach(TeachCard(
                    title: "Keep Secrets Safe",
                    body: "Don't tell AI private things — like where you live or your full name. Ask a grown-up first.",
                    symbol: "lock.fill",
                    narration: "Don't tell A.I. private things, like where you live or your full name. Ask a grown-up first.")),
                .quiz(QuizQuestion(
                    prompt: "What should you NOT share with AI?",
                    options: ["Your favorite color", "Your home address", "A story you made up"],
                    correctIndex: 1,
                    explanation: "Right! Keep private things like your address safe. Ask a grown-up if you're unsure.",
                    narration: "What should you not share with A.I.?")),
                .reflect(ReflectPrompt(
                    prompt: "You've met AI, taught it, and stayed safe. How was it?",
                    options: ["So fun!", "I learned a lot", "I have more questions"],
                    narration: "You've met A.I., taught it, and stayed safe. How was it?")),
            ]),
    ]
}
