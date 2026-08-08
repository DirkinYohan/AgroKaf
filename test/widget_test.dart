import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/main.dart';

void main() {
  testWidgets('Splash Screen renders tagline', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AgroKafApp());
    await tester.pump(const Duration(milliseconds: 1200));
    expect(
      find.text(
        'Tu aliado inteligente para detectar enfermedades del caf\u00e9',
      ),
      findsOneWidget,
    );
  });
}
