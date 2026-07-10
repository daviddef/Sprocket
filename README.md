# Sprocket — AI for Kids

An iOS app that teaches kids **what AI is, how it works, what prompts are, and
how to use it responsibly** — in simple, fun, tiered lessons. "Sprocket" is the
friendly-robot mascot (a sprocket is a gear — a little thinking machine).

Built per the validated product brief. Deliberately mirrors the sibling
**Fernby** app's conventions so the two stay mentally interchangeable: iOS 17,
iPhone-only, SwiftUI, rounded system type, a single `UserDefaults`+`Codable`
store, a "never punish a wrong answer" ethic, and forced light mode.

## What's built (v0.1)

- **Three tiered tracks** on one spine — the [AI4K12](https://ai4k12.org) *Five
  Big Ideas* — taught at rising depth (a spiral, not three separate apps):
  - **Sprouts** (5–8) — play-first, pre-reader friendly, auto-narrated
  - **Explorers** (9–12) — concept + "train it, break it, fix it" projects
  - **Builders** (13–17) — how it works, prompt craft, bias, deepfakes, ethics
- **Core loop:** onboarding → parent-gated track pick → skill map → lesson
  player (teach → do → reflect) → reward (XP, streak, badges) → next unlocks.
- **Spaced retrieval practice — the actual learning engine.** Every quiz a child
  answers is queued and returns on a five-box Leitner schedule (1/2/4/7/15
  days). Retrieval beats re-reading with medium effect sizes in real classrooms;
  by contrast, badges and leaderboards show *no* significant effect on grades.
  So XP/streaks/badges are light scaffolding only, and the mastery-bearing
  badges require stars earned or answers recalled — never mere attendance.
- **De-anthropomorphised copy.** AI *takes in data, finds patterns, gives an
  answer back*. It never "understands", "listens", "thinks" or "feels", and the
  mascot says outright that he isn't alive and that people write what he says.
  Young children readily attribute sentience to AI; the mascot has to model the
  correct language rather than undermine it.
- **Knowing when NOT to use AI** — a judgment skill taught in every tier, from
  "ask a grown-up when you feel unsafe" to "accountability can't be automated".
- **Accessible:** full Dynamic Type support (clamped at AX2, beyond which the
  phone-composed layouts break), Reduce Motion honoured app-wide, VoiceOver
  labels on non-obvious controls, and — for pre-readers — every quiz and reflect
  option individually narratable so nothing is gated behind reading.
- **Five reusable mini-games:**
  - **Sort** — two-bin sorter ("Robot or Not?", "Cat or Dog?", good vs. bad data)
  - **Decision-Tree** — walk a yes/no tree to an outcome (spam filter, verifying a claim)
  - **Prompt Improver** — compare prompts and see the answer each would produce
  - **Next Word** — predict what a language model would say next, then see its
    real probability spread. Includes a round where the likeliest word is
    *factually wrong*, which is how hallucination stops being an abstraction.
  - **Train & Test** — choose the training data, then watch the model be tested
    on examples it has never seen. The only game where the child's choices
    *cause* the model's accuracy.
- **Parent dashboard** (behind a grown-up math gate): progress, Five-Big-Ideas
  breakdown, badges, read-aloud & haptics toggles, track switch, data controls,
  and Sprocket Plus status.
- **Family profiles** — up to 6 children per device, each with their own track,
  progress, XP, streak, badges and narration preference. Kids switch themselves
  via a "Who's learning?" picker (deliberately not gated — switching to your own
  profile isn't sensitive); adding and removing children stays in the grown-up
  area. One subscription covers every child, which is what the paywall promises.
- **Sprocket Plus subscription** (StoreKit 2): the first unit of each track is
  free; the rest unlocks with a family plan (one price, every child, every
  track). Designed around Kids Category rules — a **child never sees a purchase
  button**: tapping a locked lesson shows a gentle "ask a grown-up" prompt that
  routes *through the parent gate* to the paywall. Monthly / Annual with a
  7-day free trial.
- **Private by design:** no accounts, no ads, no third-party tracking, fully
  offline (aside from the App Store purchase itself); on-device speech only.
  Privacy manifest declares zero data collection — the safest posture for the
  App Store Kids Category and the one that clears the most COPPA/GDPR-K
  obligations up front.

## Layout

```
Sprocket/
  project.yml                 xcodegen project definition
  Sprocket/
    App/                      entry point + debug launch hooks
    DesignSystem/             Theme (palette + type), SprocketButtonStyle
    Models/                   Tier, BigIdea, Curriculum, Badge, progress types
    Content/                  Curriculum+Sprouts / +Explorers / +Builders (authored in Swift)
    Services/                 ProgressStore, Haptics, SpeechService
    Views/                    Onboarding, Home (map), Lesson, MiniGames, Parent, Shared
    Assets.xcassets/          AccentColor + AppIcon
    PrivacyInfo.xcprivacy     privacy manifest (no tracking / no collection)
```

## Build & run

```sh
cd Sprocket
xcodegen generate          # regenerate Sprocket.xcodeproj after adding/removing files
open Sprocket.xcodeproj         # then run the "Sprocket" scheme
```

Command line:

```sh
xcodebuild build -project Sprocket.xcodeproj -scheme Sprocket \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

## Debug / QA launch hooks (DEBUG builds only)

Set as `SIMCTL_CHILD_*` env vars when launching in the simulator:

| Variable | Effect |
|---|---|
| `SPROCKET_DEBUG_TIER=explorers` | Seed a profile on that track → land on the home map |
| `SPROCKET_DEBUG_DONE=2` | Mark the first N units complete (screenshot mid-progress) |
| `SPROCKET_DEBUG_UNIT=sprouts.1` | Jump straight into a unit's lesson player |
| `SPROCKET_DEBUG_SCREEN=2` | Start that lesson at screen index N (e.g. a mini-game) |
| `SPROCKET_DEBUG_VIEW=parent` | Open the parent dashboard directly |
| `SPROCKET_DEBUG_VIEW=paywall` | Open the Sprocket Plus paywall directly |
| `SPROCKET_DEBUG_PLUS=1` | Force an active subscription (unlock all content) |
| `SPROCKET_DEBUG_VIEW=picker` | Open the "Who's learning?" child picker directly |
| `SPROCKET_DEBUG_KIDS="Sam:explorers:3,Mia:sprouts:6"` | Seed a family (`name:tier:unitsDone`); first child becomes active |
| `SPROCKET_DEBUG_AUTOPICK=1` | Auto-answer Next-Word / auto-train Train-and-Test, to reach their reveal states |
| `SPROCKET_DEBUG_REVIEWS=1` | Pull the whole review queue forward to today (it's due tomorrow by design) |
| `SPROCKET_DEBUG_VIEW=review` | Open a practice session directly |

> `DebugSeed` only creates a profile when none exists, so re-launching over an
> existing install silently reuses the *previous* tier and its narration
> setting. Uninstall between tier-specific checks or you'll get false results.

## Invariants worth keeping

Cheap checks that have each caught a real bug:

- **SF Symbol names** — an invalid name renders blank rather than failing the
  build. Validate every `symbol:` string against `NSImage(systemSymbolName:)`.
- **Narration must match its body.** For pre-readers narration *is* the content;
  a stale narration string once said "we say good job!" while the screen showed
  corrected text. Compare token overlap of every teach card's `body` and
  `narration`.
- **Persisted types decode leniently.** Swift's synthesized `Codable` decoder
  calls `decode()` for every property *including ones with defaults* and throws
  on a missing key. `ProgressStore` loads with `try?`, so adding a field to a
  persisted struct would silently wipe a child's history. `ProfileProgress` and
  `ReviewItem` hand-roll `init(from:)` with `decodeIfPresent`. Keep it that way.
- **Review items are keyed by question prompt, not screen index.** Inserting a
  screen shifts indices and would otherwise re-point a queued item at a
  different question, carrying the wrong box history.

## Subscription / StoreKit

`Store.storekit` defines the products (monthly `…​.monthly`, annual `…​.annual`,
7-day free trial, family-shareable) and is wired into the Sprocket scheme for
local testing — run from Xcode and real products load with no App Store Connect
setup. Launching via `simctl` doesn't inject the config, so the paywall falls
back to DEBUG placeholder prices; use `SPROCKET_DEBUG_PLUS=1` to test the
unlocked state. For production, create matching product IDs in App Store
Connect. The free/premium line lives in `Models/Gating.swift`
(`freeUnitsPerTrack`).

## Adding content

Lessons are plain Swift data in `Content/Curriculum+<Tier>.swift`. A `Unit` is
an ordered list of `LessonScreen`s (`.teach`, `.quiz`, `.game`, `.reflect`).
Add a unit, give it the next `order`, and it appears on the map automatically.

## Shipping checklist (App Store)

Things that must be done outside this repo, in App Store Connect / Xcode:

- [ ] **Create the two subscription products** in App Store Connect, in one
      subscription group, both **family-shareable**, each with a 7-day free
      trial introductory offer:
      - `com.daviddefranceski.sprocket.monthly` — $6.99/month
      - `com.daviddefranceski.sprocket.annual` — $49.99/year

      ⚠️ These IDs still carry the **old** bundle prefix (the bundle is now
      `com.defranceski.sprocket`). Product IDs are arbitrary strings and don't
      have to match the bundle ID, so they work as-is — but an IAP product ID
      is **permanent once created**, so decide before you create them. To
      rename, change `EntitlementStore.monthlyID`/`annualID` and `Store.storekit`.
- [ ] **Age rating**: 4+, and set the Kids Category age band (5 & under / 6–8 /
      9–11) — this app targets 5–17, so consider whether the Kids Category is
      the right home at all, given it caps at 11.
- [ ] **Privacy nutrition label**: answer "Data Not Collected" — it's true, and
      it's the strongest position to defend.
- [ ] **Privacy policy URL** — required for the Kids Category. Must exist and
      match `PrivacyInfo.xcprivacy` (no tracking, no collection).
- [ ] **No third-party analytics/ad SDKs** — currently true; keep it that way.
- [ ] Real-device test (everything so far is simulator-verified only).
- [ ] Bump `CURRENT_PROJECT_VERSION` if App Store Connect rejects a duplicate
      build number.

## Deliberately deferred (see the compliance brief)

No live LLM/chatbot with children in v1 — the scripted, offline design sidesteps
the largest cost and compliance risk. A gated "Ask-a-Buddy" sandbox (Builders
only, verifiable parental consent) is a considered fast-follow, not a v1
feature. Not legal advice; have counsel review before shipping.
