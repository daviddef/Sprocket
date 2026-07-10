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
                    prompt: "How do you feel about keeping your secrets safe?",
                    options: ["I've got this!", "I'll ask a grown-up", "I have questions"],
                    narration: "How do you feel about keeping your secrets safe?")),
            ]),

        // 7 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.7", tier: .sprouts, bigIdea: .perception, order: 7,
            title: "AI Can Hear",
            subtitle: "Listening computers",
            symbol: "ear.fill",
            screens: [
                .teach(TeachCard(
                    title: "Computers Can Listen",
                    body: "With a microphone, AI can hear your voice and understand the words you say.",
                    symbol: "mic.fill",
                    narration: "With a microphone, A.I. can hear your voice and understand the words you say.")),
                .teach(TeachCard(
                    title: "It Learns Sounds Too",
                    body: "Just like pictures, we teach AI sounds by playing it lots and lots of examples.",
                    symbol: "waveform",
                    narration: "Just like pictures, we teach A.I. sounds by playing it lots and lots of examples.")),
                .game(.sort(SortGame(
                    title: "Can AI Hear It?",
                    intro: "AI listens with a microphone. Which of these make a sound?",
                    binA: .init(label: "It's a Sound", symbol: "ear.fill", color: Theme.explorers),
                    binB: .init(label: "Not a Sound", symbol: "eye.fill", color: Theme.inkSoft),
                    items: [
                        .init(label: "Your voice", symbol: "waveform", inA: true),
                        .init(label: "A photo", symbol: "photo.fill", inA: false),
                        .init(label: "A dog barking", symbol: "dog.fill", inA: true),
                        .init(label: "A drawing", symbol: "paintbrush.fill", inA: false),
                        .init(label: "A doorbell", symbol: "bell.fill", inA: true),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "What does AI use to hear you?",
                    options: ["A camera", "A microphone", "A magnet"],
                    correctIndex: 1,
                    explanation: "Yes! A microphone lets AI listen. A camera is for seeing.",
                    narration: "What does A.I. use to hear you?")),
                .reflect(ReflectPrompt(
                    prompt: "Do you ever talk to an AI at home?",
                    options: ["Yes, a speaker", "Yes, a phone", "Not yet"],
                    narration: "Do you ever talk to an A.I. at home?")),
            ]),

        // 8 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.8", tier: .sprouts, bigIdea: .reasoning, order: 8,
            title: "Guess My Fruit",
            subtitle: "More thinking in steps",
            symbol: "arrow.triangle.branch",
            screens: [
                .teach(TeachCard(
                    title: "Step by Step Again",
                    body: "Computers guess by asking one small question at a time. Each answer gets them closer.",
                    symbol: "questionmark.circle.fill",
                    narration: "Computers guess by asking one small question at a time. Each answer gets them closer.")),
                .game(.decisionTree(DecisionTreeGame(
                    intro: "Think of a fruit. Answer yes or no, and watch the computer guess it!",
                    goal: "Let's guess your fruit",
                    root: .ask(
                        question: "Is it red?",
                        yes: .ask(question: "Is it small?",
                                  yes: .result("Is it a strawberry? 🍓"),
                                  no: .result("Is it an apple? 🍎")),
                        no: .ask(question: "Is it yellow?",
                                 yes: .result("Is it a banana? 🍌"),
                                 no: .result("Is it a grape? 🍇")))))),
                .quiz(QuizQuestion(
                    prompt: "What does each yes-or-no answer do?",
                    options: ["Helps narrow down the choices", "Makes the computer forget", "Starts it all over"],
                    correctIndex: 0,
                    explanation: "Right! Every answer removes some choices, until just one is left.",
                    narration: "What does each yes or no answer do?")),
                .reflect(ReflectPrompt(
                    prompt: "Did the computer guess your fruit?",
                    options: ["Yes!", "No, I tricked it"],
                    narration: "Did the computer guess your fruit?")),
            ]),

        // 9 ──────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.9", tier: .sprouts, bigIdea: .learning, order: 9,
            title: "Oops! AI Mistakes",
            subtitle: "AI can be wrong",
            symbol: "exclamationmark.triangle.fill",
            screens: [
                .teach(TeachCard(
                    title: "AI Makes Mistakes",
                    body: "Sometimes AI guesses wrong. It might even call a muffin a puppy! It isn't perfect.",
                    symbol: "exclamationmark.triangle.fill",
                    narration: "Sometimes A.I. guesses wrong. It might even call a muffin a puppy! It isn't perfect.")),
                .teach(TeachCard(
                    title: "We Help It Learn",
                    body: "When AI is wrong, we show it the right answer. Then it does better next time.",
                    symbol: "arrow.up.heart.fill",
                    narration: "When A.I. is wrong, we show it the right answer. Then it does better next time.")),
                .game(.sort(SortGame(
                    title: "Good Guess or Oops?",
                    intro: "The AI made some guesses. Which are right, and which are an oops?",
                    binA: .init(label: "Good Guess", symbol: "hand.thumbsup.fill", color: Theme.correct),
                    binB: .init(label: "Oops!", symbol: "hand.thumbsdown.fill", color: Theme.gentle),
                    items: [
                        .init(label: "\"That cat is a cat\"", symbol: "cat.fill", inA: true),
                        .init(label: "\"That muffin is a puppy\"", symbol: "dog.fill", inA: false),
                        .init(label: "\"The sky is blue\"", symbol: "cloud.fill", inA: true),
                        .init(label: "\"The sun is cold\"", symbol: "sun.max.fill", inA: false),
                    ]))),
                .quiz(QuizQuestion(
                    prompt: "AI tells you something strange. What do you do?",
                    options: ["Believe it right away", "Check with a grown-up", "Get upset"],
                    correctIndex: 1,
                    explanation: "Yes! Always check surprising things with a grown-up you trust.",
                    narration: "A.I. tells you something strange. What do you do?")),
                .reflect(ReflectPrompt(
                    prompt: "Is it okay to make mistakes?",
                    options: ["Yes — that's how we learn!", "I'm not sure"],
                    narration: "Is it okay to make mistakes?")),
            ]),

        // 10 ─────────────────────────────────────────────────────────────
        Unit(
            id: "sprouts.10", tier: .sprouts, bigIdea: .impact, order: 10,
            title: "AI All Around Us",
            subtitle: "People are the boss",
            symbol: "sparkles",
            screens: [
                .teach(TeachCard(
                    title: "AI Helps People",
                    body: "AI helps doctors spot illness, helps farmers grow food, and can even help make music!",
                    symbol: "heart.text.square.fill",
                    narration: "A.I. helps doctors spot illness, helps farmers grow food, and can even help make music!")),
                .teach(TeachCard(
                    title: "You're the Boss",
                    body: "AI is a tool, like a pencil or a bike. People choose how to use it. Choose to be kind.",
                    symbol: "person.fill.checkmark",
                    narration: "A.I. is a tool, like a pencil or a bike. People choose how to use it. Choose to be kind.")),
                .quiz(QuizQuestion(
                    prompt: "Who decides how AI is used?",
                    options: ["People", "The AI itself", "Nobody"],
                    correctIndex: 0,
                    explanation: "That's right! People build AI and people choose how to use it — including you.",
                    narration: "Who decides how A.I. is used?")),
                .reflect(ReflectPrompt(
                    prompt: "You finished the whole track! What was your favorite part?",
                    options: ["Teaching the puppy", "The treasure map", "Talking to AI", "All of it!"],
                    narration: "You finished the whole track! What was your favorite part?")),
            ]),
    ]
}
