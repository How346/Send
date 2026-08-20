import 'package:flutter_test/flutter_test.dart';
import 'package:hyperdrop/app.dart';

void main() {
  testWidgets('HyperDrop starts', (tester) async {
    await tester.pumpWidget(const HyperDropApp());

    expect(find.text('HyperDrop'), findsOneWidget);
  });
}
