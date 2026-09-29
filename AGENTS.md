# AI Agent Guidelines

Last updated: 2026-09-28

---

## Project

**flutter_carousel_widget** is a carousel for Flutter: `FlutterCarousel` for items of one size and `ExpandableCarousel` for items that size themselves, both on one engine, with ten composable effects, lifecycle-aware autoplay, repaint-only indicators, keyboard navigation and screen-reader semantics. It imports `widgets.dart` and its lower layers only, never Material or Cupertino, so it works in any app.

| Area          | Detail                                                                                          |
| ------------- | ----------------------------------------------------------------------------------------------- |
| Language      | Dart 3.13, Flutter `>=3.47.0`, `widgets.dart` only                                              |
| Runtime deps  | none besides `flutter`                                                                          |
| Tests         | `flutter_test` with leak tracking; one regression test per 3.1.1 defect; a README snippet guard |
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

`dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `(cd example && flutter test)`, `flutter pub publish --dry-run`. CI's `build` job runs the first four plus a 90% coverage gate (`flutter test --coverage`, then `scripts/coverage.sh 90`); the `floor` job analyzes and tests on Flutter 3.47.0. `.githooks/pre-push` runs them too (`git config core.hooksPath .githooks`). `example.yml` builds the example app for Android, iOS, macOS, Windows, Linux and web (JS and Wasm) on every PR to `master`; the example's native icons come from `example/assets/icon` via `cd example && dart run flutter_launcher_icons`.

### Conventions

- Conventional Commits, imperative subject `<=` 50 chars, no trailing period, no `Co-Authored-By` or `Generated with` trailers.
- Every PR that changes anything users receive bumps `pubspec.yaml` and adds a matching `CHANGELOG.md` entry. CI gate `version bumped` enforces both, and without the entry `dart pub publish --dry-run` fails, which stops the release workflow before it publishes.
- The PR title becomes the squash commit message.
- `master` is protected: PR required, squash-only merges.
- The README documents **shipped features only** - no roadmap, no plans. Every Dart block in it must also be in `test/readme_snippets.dart`, verbatim, or `readme_test.dart` fails.
- Markdown prose is never hard-wrapped: one line per paragraph and per list item. Do not re-wrap these files to a column.
- Never use an em-dash. Use a hyphen.

### Things that will bite you

- **An effect must return the same widget structure at every offset**, or items remount as they cross the centre and lose their state. Vary the values (identity transforms, opacity 1), never the widgets.
- **Never `setState` the carousel per scroll frame.** Effects and indicators listen to the `PageController` themselves; with no effect, items do not rebuild during a drag, and a test pins that.
- **A new `PageController` absorbs the old one's pixels**, so page moves after a controller swap or an item change happen after the frame.
- **Shrinking items clamps the position during layout without a scroll notification**, so the engine reports that page change itself. It also corrects the pixels before that layout, or the moved keyed pages are garbage-collected past the old end and lose their state.
- **`SliverChildBuilderDelegate` needs item keys wrapped with the copy index** (`_PageKey`), or an infinite carousel showing an item twice has two equal keys.
- **Flush edges do not use `PageView`'s page.** With `CarouselEdgeAlignment.flush`, the index, position and snapping come from the clamped settle offsets; `pixels / extent` is off by up to a page near the edges.
- **Flutter 3.47's `pub get` rewrites `analysis_options.yaml`** (root and example) to exclude `build/` and the platform directories present. Commit it with the platform change, and revert it on a branch that lacks those directories.
- **Attach and detach notify the controller after the frame**; the tree is locked or building when they happen.
- **`lib/` never imports Material**; `test/architecture_test.dart` fails if it does.
- **Colours round-trip through `Paint` as floats.** Compare a painted colour as 8-bit ARGB (`toARGB32()`), as `RecordingCanvas` does, or `0x66FFFFFF` never matches.

---

## Always-Active Instructions

> These apply to EVERY interaction, automatically.

### Working Discipline

> Behavioral guidelines to reduce common LLM coding mistakes. Bias toward caution over speed; for trivial tasks, use judgment.

#### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- Read existing code and understand patterns before proposing changes.
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

#### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

#### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

#### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

#### 5. Report What Was Done

After completing work, state what changed and why - not just that it's done.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

### Multi-Agent Safety Rules

- **Never** create/apply/drop git stash entries unless explicitly requested
- **Never** edit files in `node_modules/`, `vendor/`, or other dependency directories
- **Always** work on a dedicated branch when running concurrent agents
- **Never** force-push or rebase shared branches from an agent session
- **Verify** no other agent is modifying the same files before making changes

### Release Safety

- **Never** merge a PR or publish to pub.dev without explicit approval. Merging `master` triggers the tag and the pub.dev publish in one shot, and a published version number can never be reused or unpublished.
- A publish run can exit non-zero **after** publishing successfully. A red Publish check means "check pub.dev for the version" rather than "it failed".

---
