import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Every widget test tracks leaks; a PageController or Timer left behind by the
/// carousel fails the test that created it.
FutureOr<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    createdByTestHelpers: true,
  );
  await testMain();
}
