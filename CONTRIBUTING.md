# Contributing to flutter_carousel_widget

Thanks for your interest in contributing. flutter_carousel_widget is a carousel for Flutter built on `widgets.dart` alone, and contributions that make carousels smoother, more accessible or easier to build are very welcome.

## Code of Conduct

Please review and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). We expect all contributors to be respectful, considerate, and inclusive when interacting with the project and its community.

## Getting set up

Requires Flutter 3.47 or newer.

```bash
git clone https://github.com/nixrajput/flutter_carousel_widget.git
cd flutter_carousel_widget
flutter pub get
git config core.hooksPath .githooks   # optional: runs the checks below before each push
```

`flutter pub get` resolves the example app too.

## The checks

Every one of these must pass before a PR can merge. CI runs all of them but the publish dry run, which the release workflow runs before every publish:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
(cd example && flutter test)
flutter pub publish --dry-run
```

CI also holds line coverage at 90% (`scripts/coverage.sh 90`) and repeats analyze and test on Flutter 3.47.0, the floor.

## Workflow

1. **Fork and branch.** Branch off `master` with a descriptive name (`feat/cube-perspective`, `fix/expandable-height`).
2. **Write the test first.** Every feature and bugfix lands with a test. Bugs get a test that reproduces them before the fix.
3. **Keep the diff surgical.** Every changed line should trace to the change you are making. No drive-by refactors, no speculative abstractions.
4. **Bump the version.** `pubspec.yaml` must move in every PR, with a matching `CHANGELOG.md` entry - CI enforces both (`version bumped`). Patch for fixes, minor for features.
5. **Update the docs.** If behaviour a user can see changes, the README changes in the same PR, and every Dart block in it must also be in `test/readme_snippets.dart`.
6. **Open the PR.** Fill in the template. The PR title becomes the squash commit message on merge, so write it in Conventional Commit form (`feat: add a cube effect`) and keep it under ~50 characters.

## Keeping the carousel correct

Three rules keep the carousel correct and fast:

- An effect never changes its widget structure with the offset; it changes values. A different structure remounts the item and loses its state.
- Nothing rebuilds the carousel per scroll frame. Effects and indicators listen to the scroll position themselves.
- `lib/` never imports Material or Cupertino. `test/architecture_test.dart` fails if it does.

## Conventions

- **Commits:** Conventional Commits (`feat:`, `fix:`, `docs:`, `ci:`, `chore:`, `refactor:`), imperative subject, no trailing period.
- **Style:** `dart format` and the lints in `analysis_options.yaml`, including `public_member_api_docs`: every public API element carries a doc comment.
- **Language:** Dart 3.13, Flutter `>=3.47.0`, and `widgets.dart` only: `lib/` never imports Material or Cupertino, so the carousel works in any app.
- **Dependencies:** none besides `flutter`. Please do not add one without discussing it in an issue first.
- **Comments:** explain why, not what. Most code needs none.

## Reporting issues

Bugs and feature requests go to [Issues](https://github.com/nixrajput/flutter_carousel_widget/issues) - the templates ask for the Flutter version, the platforms and a minimal repro, which is usually enough to act on. Questions and open-ended ideas belong in [Discussions](https://github.com/nixrajput/flutter_carousel_widget/discussions). Security issues follow [SECURITY.md](SECURITY.md) instead - never a public issue.

## Thank you

Every issue, repro, and PR makes this project more useful. Thanks for taking the time.
