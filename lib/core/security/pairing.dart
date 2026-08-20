import 'dart:math';
import 'dart:typed_data';

class Pairing {
  static final Random _random = Random.secure();

  static String code() => (_random.nextInt(1000000)).toString().padLeft(6, '0');

  static String displayCode(String code) =>
      '${code.substring(0, 3)} ${code.substring(3)}';

  static Uint8List sasBytes(String code) =>
      Uint8List.fromList(code.codeUnits);
}
