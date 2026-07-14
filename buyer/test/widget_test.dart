// Basic sanity test for the Buyer app.
//
// The default counter test was removed when the buyer module was ported in
// (MyApp now requires an AppConfig and the app wires up GetIt at startup,
// which a naive widget pump can't satisfy). This test verifies the flavor
// configuration the app boots with instead.

import 'package:flutter_test/flutter_test.dart';

import 'package:buyer/core/config/app_flavor.dart';

void main() {
  test('Dev flavor config points at the dev API', () {
    final config = AppConfig.fromFlavor(AppFlavor.dev);

    expect(config.flavor, AppFlavor.dev);
    expect(config.baseUrl, 'https://api.demo.paysft.com');
    expect(config.enableLogging, isTrue);
  });
}
