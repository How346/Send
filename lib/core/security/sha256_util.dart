import 'dart:io';
import 'package:crypto/crypto.dart';

Future<String> sha256File(File file, {int chunkSize = 1024 * 1024}) async {
  final digest = AccumulatorSink<Digest>();
  final input = sha256.startChunkedConversion(digest);
  final stream = file.openRead();
  await for (final chunk in stream) {
    input.add(chunk);
  }
  input.close();
  return digest.events.single.toString();
}
