## Summary

<!-- What does this PR do? One paragraph is enough. -->

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Refactor / code cleanup
- [ ] Documentation
- [ ] CI / tooling
- [ ] Dependency update

## Related issues

Closes #<!-- issue number -->

## How to test

<!-- Steps for a reviewer to verify the change manually. -->

1.
2.

## Verification checklist

- [ ] `dart format --output=none --set-exit-if-changed .` - clean
- [ ] `flutter analyze` - 0 issues
- [ ] `flutter test` - all tests pass
- [ ] `(cd example && flutter test)` - layout tests pass
- [ ] `flutter pub publish --dry-run` - no warnings
- [ ] `pubspec.yaml` version bumped (required to merge)
- [ ] `CHANGELOG.md` has an entry for that version (`flutter pub publish --dry-run` fails without one, so the release workflow stops)
- [ ] Docs updated where applicable (README, dartdoc comments)
- [ ] Checked under RTL, `reverse`, the vertical axis and a screen reader where the change can reach them
- [ ] No per-frame rebuild added: effects and indicators read the scroll listenable
- [ ] `SECURITY.md` supported-versions table still correct
- [ ] No unrelated changes included in this PR
