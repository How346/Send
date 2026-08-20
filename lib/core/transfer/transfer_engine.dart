import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import '../models.dart';
import '../protocol/frame.dart';
import '../security/sha256_util.dart';
import '../security/path_security.dart';

class TransferEngine {
  static const int chunkSize = 1024 * 1024;

  Future<void> sendFile({
    required Socket socket,
    required TransferItem item,
    void Function(int offset, double bytesPerSecond)? onProgress,
  }) async {
    final file = File(item.path);
    final size = await file.length();
    final hash = await sha256File(file);
    await FrameCodec.writeJson(socket, {
      'type': 'file_start',
      'id': item.id,
      'name': PathSecurity.sanitizeFileName(item.name),
      'size': size,
      'sha256': hash,
      'offset': item.offset,
    });

    final raf = await file.open();
    try {
      await raf.setPosition(item.offset);
      var offset = item.offset;
      final stopwatch = Stopwatch()..start();
      while (offset < size) {
        final want = (size - offset) > chunkSize ? chunkSize : (size - offset);
        final data = await raf.read(want);
        if (data.isEmpty) throw const FileSystemException('Unexpected EOF');
        final frame = BytesBuilder();
        final header = ByteData(16)
          ..setInt64(0, offset)
          ..setInt64(8, data.length);
        frame.add(header.buffer.asUint8List());
        frame.add(data);
        await FrameCodec.writeBytes(socket, frame.takeBytes());
        offset += data.length;
        item.offset = offset;
        final seconds = stopwatch.elapsedMicroseconds / 1000000;
        onProgress?.call(offset, seconds <= 0 ? 0 : offset / seconds);
      }
    } finally {
      await raf.close();
    }
    await FrameCodec.writeJson(socket, {'type': 'file_end', 'id': item.id});
  }

  Future<File> receiveFile({
    required Socket socket,
    required StreamIterator<List<int>> iterator,
    required String root,
    required String relativeName,
    required int size,
    required String expectedSha256,
    required int resumeOffset,
    required void Function(int offset, double bytesPerSecond)? onProgress,
  }) async {
    await PathSecurity.ensureRoot(root);
    final safeName = PathSecurity.sanitizeFileName(p.basename(relativeName));
    final finalPath = PathSecurity.safeChild(root, safeName);
    final partPath = '$finalPath.hyperdrop.part';

    final part = File(partPath);
    var offset = 0;
    if (await part.exists()) {
      offset = await part.length();
      if (offset > size) {
        await part.delete();
        offset = 0;
      }
    }

    final sink = part.openWrite(mode: FileMode.append);
    final stopwatch = Stopwatch()..start();
    try {
      while (offset < size) {
        final payload = await _readBinary(iterator);
        if (payload.length < 16) throw const FormatException('Invalid chunk');
        final data = payload.sublist(16);
        final bd = ByteData.sublistView(payload);
        final declaredOffset = bd.getInt64(0);
        final declaredLength = bd.getInt64(8);
        if (declaredOffset != offset || declaredLength != data.length || offset + data.length > size) {
          throw const FormatException('Invalid chunk offset/length');
        }
        sink.add(data);
        offset += data.length;
        final seconds = stopwatch.elapsedMicroseconds / 1000000;
        onProgress?.call(offset, seconds <= 0 ? 0 : offset / seconds);
      }
    } finally {
      await sink.close();
    }

    final actual = await sha256File(part);
    if (actual != expectedSha256) {
      throw const FormatException('SHA-256 verification failed');
    }

    final unique = await _nonClobbering(finalPath);
    await part.rename(unique);
    return File(unique);
  }

  Future<String> _nonClobbering(String desired) async {
    if (!await File(desired).exists()) return desired;
    final dir = p.dirname(desired);
    final base = p.basenameWithoutExtension(desired);
    final ext = p.extension(desired);
    for (var i = 1; i < 100000; i++) {
      final candidate = p.join(dir, '$base ($i)$ext');
      if (!await File(candidate).exists()) return candidate;
    }
    throw const FileSystemException('Could not choose a duplicate-safe filename');
  }

  Future<Uint8List> _readBinary(StreamIterator<List<int>> iterator) async {
    final header = <int>[];
    while (header.length < 4) {
      if (!await iterator.moveNext()) throw const SocketException('Connection closed');
      header.addAll(iterator.current);
    }
    final length = ByteData.sublistView(Uint8List.fromList(header.take(4).toList())).getUint32(0, Endian.big);
    if (length < 16 || length > 2 * 1024 * 1024) throw const FormatException('Invalid binary frame');
    final out = BytesBuilder(copy: false);
    final first = header.length > 4 ? header.sublist(4) : const <int>[];
    if (first.isNotEmpty) out.add(first);
    var left = length - first.length;
    while (left > 0) {
      if (!await iterator.moveNext()) throw const SocketException('Connection closed');
      final part = iterator.current;
      final take = part.length > left ? part.sublist(0, left) : part;
      out.add(take);
      left -= take.length;
    }
    return out.takeBytes();
  }
}
