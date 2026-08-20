import 'dart:io';

import 'package:crypto/crypto.dart';

Future<String> sha256File(
  File file, {
  int chunkSize = 1024 * 1024,
}) async {
  final digestStream = sha256.bind(
    file.openRead(
      0,
      null,
    ),
  );

  final digest = await digestStream.first;

  return digest.toString();
}
