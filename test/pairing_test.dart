import 'package:flutter_test/flutter_test.dart';
import 'package:hyperdrop/core/security/pairing.dart';

void main() {
  test('pairing code is six digits', () {
    final code = Pairing.code();
    expect(code, matches(RegExp(r'^\d{6}$')));
  });
}
