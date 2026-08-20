import 'package:flutter_test/flutter_test.dart';
import 'package:hyperdrop/core/models.dart';

void main() {
  test('progress is bounded', () {
    final t = TransferItem(id: 'x', path: 'x', name: 'x', size: 100);
    t.offset = 250;
    expect(t.progress, 1);
  });
}
