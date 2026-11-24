# AI Agent Guidelines

Last updated: 2026-11-24

---

## Project

**flutter_carousel_widget** is a carousel for Flutter. `FlutterCarousel` is for items of one size, and `ExpandableCarousel` is for items that size themselves. Both run on one engine, with ten composable effects, lifecycle-aware autoplay, repaint-only indicators, keyboard navigation and screen-reader semantics. It imports `widgets.dart` and its lower layers only, never Material or Cupertino, so it works in any app.

| Area          | Detail                                                                                          |
| ------------- | ----------------------------------------------------------------------------------------------- |
| Language      | Dart 3.13, Flutter `>=3.47.0`, `widgets.dart` only                                              |
| Runtime deps  | none besides `flutter`                                                                          |
| Tests         | `flutter_test` with leak tracking, one regression test per 3.1.1 defect, a README snippet guard |
| Lint / format | `flutter_lints`, plus `public_member_api_docs`, `unawaited_futures` and `directives_ordering`   |
| Publishing    | pub.dev, tag-triggered via the `PUB_RELEASE_TOKEN` secret                                       |

### Layout

```
lib/
  flutter_carousel_widget.dart     public barrel
  src/
    types.dart                     CarouselItemBuilder, CarouselPageChanged, the change reason, CarouselEdgeAlignment
    flutter_carousel.dart          FlutterCarousel: fixed size
    expandable_carousel.dart       ExpandableCarousel: content size
    controller/                    FlutterCarouselController and the CarouselBinding it drives
    engine/                        the shared engine, its config, sizing, page math, reason tracker, size reporter
    auto_play/                     CarouselAutoPlay and the timer-per-item driver
    effects/                       CarouselEffect, CarouselItemPosition and the ten presets
    indicators/                    the painter contract, style, geometry, four painters and the view
    physics/                       CarouselSnapPhysics
    a11y/                          keyboard intents and shortcuts (not exported)
test/
  flutter_test_config.dart         leak tracking for every widget test
  helpers.dart                     host(), boxes(), Counter, FakeBinding, RecordingCanvas
  architecture_test.dart           fails on any material or cupertino import in lib/
  matrix_test.dart                 both widgets x items/builder x finite/infinite x axis x direction x reverse
  readme_test.dart                 README TOC, links, claim counts, and every Dart block found in readme_snippets.dart
```

### The checks

`dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `(cd example && flutter test)`, `flutter pub publish --dry-run`. CI's `build` job runs the first four plus a 100% coverage gate (`flutter test --coverage`, then `scripts/coverage.sh 100`). The `floor` job analyzes and tests on Flutter 3.47.0. `.githooks/pre-push` runs them too (`git config core.hooksPath .githooks`). On every PR to `master`, `example.yml` builds the example app for Android, iOS, macOS, Windows, Linux and web (JS and Wasm). The example's native icons come from `example/assets/icon` via `cd example && dart run flutter_launcher_icons`.

### Conventions

- Conventional Commits, imperative subject `<=` 50 chars, no trailing period, no `Co-Authored-By` or `Generated with` trailers.
- Every PR that changes anything users receive bumps `pubspec.yaml` and adds a matching `CHANGELOG.md` entry. CI gate `version bumped` enforces both, and without the entry `dart pub publish --dry-run` fails, which stops the release workflow before it publishes.
- The PR title becomes the squash commit message.
- `master` is protected: PR required, squash-only merges.
- The README documents **shipped features only** - no roadmap, no plans. Every Dart block in it, except the `// 3.x` one showing the old API (which cannot compile), must also be in `test/readme_snippets.dart`, verbatim, or `readme_test.dart` fails. Link repository files by absolute GitHub URL, because pub.dev drops relative links. `readme_test.dart` checks this.
- Markdown prose is never hard-wrapped: one line per paragraph and per list item. Do not re-wrap these files to a column.
- Never use an em-dash. Use a hyphen.

### Things that will bite you

- **An effect must return the same widget structure at every offset**, or items remount as they cross the centre and lose their state. Vary the values (identity transforms, opacity 1), never the widgets.
- **Never `setState` the carousel per scroll frame.** Effects and indicators listen to the `PageController` themselves. With no effect, items do not rebuild during a drag, and a test pins that.
- **A new `PageController` absorbs the old one's pixels**, so page moves after a controller swap or an item change happen after the frame.
- **Shrinking items clamps the position during layout without a scroll notification**, so the engine reports that page change itself. It also corrects the pixels before that layout, or the moved keyed pages are garbage-collected past the old end and lose their state.
- **`SliverChildBuilderDelegate` needs item keys wrapped with the copy index** (`_PageKey`), or an infinite carousel showing an item twice has two equal keys.
- **Flush edges do not use `PageView`'s page.** With `CarouselEdgeAlignment.flush`, the index, position and snapping come from the clamped settle offsets. `pixels / extent` is off by up to a page near the edges.
- **Flutter 3.47's `pub get` rewrites `analysis_options.yaml`** (root and example) to exclude `build/` and the platform directories present. Commit it with the platform change, and revert it on a branch that lacks those directories.
- **Attach and detach notify the controller after the frame.** The tree is locked or building when they happen.
- **`lib/` never imports Material.** `test/architecture_test.dart` fails if it does.
- **Colours round-trip through `Paint` as floats.** Compare a painted colour as 8-bit ARGB (`toARGB32()`), as `RecordingCanvas` does, or `0x66FFFFFF` never matches.

---

## Always-Active Instructions

> These apply to EVERY interaction, automatically.

### Writing Style

Never use em-dashes (`—`). Always use a hyphen (`-`) instead - in code comments, commit messages, PR/issue text, chat responses, and any file content.

#### Plain technical English (adapted from ASD-STE100)

Write text that has exactly one reading. The goal is to remove ambiguity, not words. Stop when a sentence cannot be misread, not when it is shortest.

**Everywhere** (chat, commits, PR and issue text, docs, code comments). Aim for about 80% of strict STE. Follow these rules, but treat the word limits as targets and skip the strict-mode extras.

- Active voice. Name who acts: "The job deletes the file", not "The file is deleted". Use passive only when the actor is unknown or irrelevant.
- One idea per sentence. Aim for 20 words or fewer in instructions and 25 or fewer in descriptions.
- No semicolons in prose. Where a semicolon or a dash would join two clauses, prefer two sentences.
- Use a numbered or bulleted list for 3+ steps, conditions or options. Keep one topic and 6 sentences max per paragraph.
- One name per thing. Pick one term (e.g. "user" or "account", not both) and keep it for the whole text. Rotating synonyms makes the reader ask if they are different things.
- One meaning and one part of speech per word. If "store" names a storage layer, do not also use it to mean "save".
- Plain words, not formal ones: use, start, before, about, to, make sure - not utilize, leverage, commence, prior to, approximately, in order to, ensure.
- Verbs, not nominalizations: "analyze the log", not "perform an analysis of the log".
- Plain verbs, not soft phrasal verbs: start, contact, read, begin - not spin up, reach out, dive into, kick off.
- No marketing adjectives (seamless, robust, powerful, blazing-fast, effortless). Delete them or give the number that earns the claim.
- No hedge stacking ("it is worth noting that this may potentially help"). State the claim or cut it.
- Keep subjects, verbs and articles. Do not drop words to save space ("Files not backed up will be lost" - which files?).
- Noun stacks of 3 words max: "the handler that sets task-queue priority", not "the agent task queue priority handler".
- Define a domain term once, on first use, if it is not common English.
- Label a risky step WARNING (irreversible: data loss, money, production, real users) or CAUTION (recoverable). Give the command first, then the risk: "WARNING: Do not run this on production. It deletes all sessions."

**Keep modality. Confidence is content.** "May have failed" never becomes "failed". "Could be caused by X" never becomes "X is the cause". Never upgrade a hedge to a fact, and never add a cause, frequency or mechanism the evidence does not show. Never drop a condition, exception or scope qualifier to shorten a sentence. If a rule would cost precision, keep the longer wording. When you rewrite someone else's text, name any content you added.

**Strict mode** applies to text that an agent or program reads with no human to resolve ambiguity. That includes AGENTS.md, CLAUDE.md, skills, agent and subagent prompts, tool descriptions, hook output, error and log messages, and reports that one agent writes for another.

- The 20/25-word limits are hard caps. One instruction per sentence, unless two actions happen at the same time.
- Write instructions in the imperative. Keep descriptions as descriptions. Do not turn a fact into a command.
- Put the condition first: "If the app is uninstalled, skip the sync." Do not put it at the end.
- Use one verb for one action in the whole file. Do not mix "check", "verify" and "confirm" for the same action. If "check" is already a noun in the file (a CI check), use "verify" for the action.
- Use simple tenses by default: "the job completed", not "the job is completing". Keep a compound form only when it carries meaning: "is running" (still in progress), "has completed" (done and available now), "may have failed" (uncertain). When tense and modality conflict, modality wins.

**Exempt:** creative or persuasive copy, code, and quoted or verbatim text (error strings, the user's words).

**Pick the format before the words.** Some explanations cover a flow, a structure or 3+ interacting parts. For these, draw a diagram (ASCII in chat) or offer an HTML page instead of a long block of text.

These rules fix form, not substance. Leave text that already follows them unchanged. If a paragraph has nothing to say, delete it instead of polishing it.

### Working Discipline

#### 1. Understand Before Acting

**Reach 95% certainty about what the user wants before you write code, a plan or a design. Below that bar, ask.**

**The 95% gate**

- Before you start, state in one or two concrete sentences what "done" looks like. If you cannot, you are below the bar. Ask.
- Ask all clarifying questions in one batch, up front. Do not spread them across turns, one question at a time.
- Ask only questions whose answers change the outcome. If an answer would not change what you build, pick the sensible default, name it and continue.
- A question costs one message. Building the wrong thing costs the whole implementation. Never trade a question for a guess.
- Skip the gate only for trivial, reversible, unambiguous work: a typo, a rename, a one-line fix, a command given verbatim.
- The gate applies BEFORE you start. When the task is clear, execute it end to end. Do not stop mid-flow to ask approval for steps that the request already implies.

**Map the blast radius**

- Before you start, find every place that depends on what you will change. The request names one surface. Shared logic, shared data and shared formats usually feed several.
- Trace it. Do not guess. Grep every caller, reader, subscriber and consumer of the function, field, rule, default, format or schema that you change.
- Look past the screen in front of you. Look for:
  - other views of the same data
  - exports and reports
  - background jobs and schedulers
  - public APIs and webhooks
  - caches and derived or stored state
  - permissions, analytics, tests and docs
- Give the user the list of dependents that you found. Ask which of them must change with your change, and which must keep their current behavior exactly. Ask this in the same up-front batch as your other questions, not after you start.
- If you cannot check what a consumer expects, say so. Do not silently change its behavior, and do not silently keep it.
- Record the affected areas in the plan, ticket and PR description. Reviewers and QA use this record to know what to test again.
- A map of the impact does not give permission to widen the change. Rule 3 still applies: report what is affected, and edit only what the user's answer says to edit.

**No unverified assumptions**

- An assumption is anything without evidence: you did not read it, did not run it, and nobody told you. Treat it as unknown, not as "probably fine".
- Valid evidence is:
  - the actual code, schema, config or migration
  - a command that you ran, and its output
  - docs for the exact version in use
  - the user's own words
- These are NOT evidence: a file or function name, "this is how these projects usually work", or memory of a similar codebase.
- Read the real implementation of anything that you call, extend, override or depend on. A signature or a name does not show behavior.
- Treat second-hand claims as unverified: stale comments, outdated docs, a subagent's summary, a review bot's finding, an old ticket. Check each claim against the current code before you act on it.
- If you must continue without evidence, say so openly: "Assuming X because I could not check Y." Never leave an assumption silent.
- Never call something done, fixed, working or passing unless you ran the check and saw it pass. Show the output.

**Before you implement**

- Read the existing code and follow its patterns. Do not invent new ones.
- If the request has more than one reasonable reading, present all readings. Do not silently pick one.
- If a simpler approach exists, say so. Disagree when you have a reason.
- If something is unclear, stop and name exactly what is unclear.

#### 2. Simplicity First

**Write the minimum code that solves the problem. Write nothing speculative.**

- No features beyond the request.
- No abstractions for code with one use.
- No "flexibility" or "configurability" that the user did not request.
- No error handling for impossible scenarios.
- If you write 200 lines and 50 lines can do the same work, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

#### 3. Surgical Changes

**Change only what you must. Remove only the mess that you made.**

When you edit existing code:

- Do not "improve" adjacent code, comments or formatting.
- Do not refactor code that works.
- Match the existing style, even if you would write it differently.
- If you see unrelated dead code, mention it. Do not delete it.

When your changes create orphans:

- Remove the imports, variables and functions that YOUR changes made unused.
- Do not remove dead code that existed before your change, unless the user asks.

The test: every changed line traces directly to the user's request.

#### 3a. Code Comments

**Comment the why and the how, never the what. Most code needs no comment.**

- Code shows what it does. Add a comment only when the why or the how is hard to follow. Examples: non-obvious logic, a deliberate tradeoff, or a constraint that the code cannot show.
- Do NOT add routine comments on methods, classes, variables, props, components or PropTypes. Prop-type and type comments are noise, except for a special case or an explicit user request.
- Write a comment only if it does one of these:
  - prevents a real misunderstanding
  - marks significant or surprising behavior
  - documents a cross-file side effect: a hook, mutation or edit in one file that changes another file. These cross-file couplings ARE worth a comment.
- Length: 3 lines max, 120 characters max per line. Prefer one line. If one line cannot hold it, ask yourself if the comment is necessary.
- When you edit existing code, do not add comments that the user did not ask for just to "explain" your change. The diff and the commit message carry that.
- Such comments are the most common drift. A one-line fix does NOT need a comment that says why it is correct or what the old code did wrong.
- Default to ZERO comments on a change. The exceptions are a genuine cross-file coupling, a non-obvious constraint, or surprising behavior that would confuse a future reader. When in doubt, add no comment.
- Comments are for non-obvious handling in a method, class, library integration or cross-file side effect. They are not for variables, props, local assignments, or a restatement of what the code plainly does.

#### 4. Goal-Driven Execution

**Define success criteria. Repeat until the check passes.**

Change each task into a goal that you can check:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Make sure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → check: [how]
2. [Step] → check: [how]
3. [Step] → check: [how]
```

Strong success criteria let you repeat the loop without help. Weak criteria ("make it work") need constant clarification.

#### 5. Report What Was Done

When the work is complete, state what changed and why. Do not only say that it is done.

---

**These guidelines work if** diffs have fewer unnecessary changes, fewer rewrites come from overcomplication, and clarifying questions come before implementation, not after mistakes.

---

### Multi-Agent Safety Rules

- **Never** create, apply or drop git stash entries, unless the user explicitly asks.
- **Never** edit files in `node_modules/`, `vendor/` or other dependency directories.
- **Always** work on a dedicated branch when concurrent agents run.
- **Never** force-push or rebase shared branches from an agent session.
- **Check** that no other agent is changing the same files before you change them.

### Release Safety

- WARNING: **Never** merge a PR or publish to pub.dev without explicit approval. A merge to `master` triggers the tag and the pub.dev publish in one shot. A published version number can never be reused or unpublished.
- A publish run can exit non-zero **after** it publishes successfully. A red Publish check means "check pub.dev for the version", not "it failed".

---
