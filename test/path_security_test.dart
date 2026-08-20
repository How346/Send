import 'package:flutter_test/flutter_test.dart';
import 'package:hyperdrop/core/security/path_security.dart';

void main() {
  test('rejects traversal', () {
    expect(() => PathSecurity.safeChild('/tmp/root', '../secret'), throwsFormatException);
    expect(() => PathSecurity.safeChild('/tmp/root', '/etc/passwd'), throwsFormatException);
  });

  test('sanitizes unsafe filename characters', () {
    expect(PathSecurity.sanitizeFileName('a:b?.txt'), 'a_b_.txt');
    expect(PathSecurity.sanitizeFileName('CON.txt'), '_CON.txt');
  });
}
