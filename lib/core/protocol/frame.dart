import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FrameCodec {
  static const maxFrame = 1024 * 1024;

  static Future<void> writeJson(Socket socket, Map<String, dynamic> value) async {
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(value)));
    await _write(socket, bytes);
  }

  static Future<Map<String, dynamic>> readJson(StreamIterator<List<int>> it) async {
    final bytes = await _read(it);
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map<String, dynamic>) throw const FormatException('Invalid control frame');
    return value;
  }

  static Future<void> writeBytes(Socket socket, Uint8List bytes) => _write(socket, bytes);

  static Future<void> _write(Socket socket, Uint8List payload) async {
    if (payload.length > maxFrame) throw const FormatException('Frame too large');
    final header = ByteData(4)..setUint32(0, payload.length, Endian.big);
    socket.add(header.buffer.asUint8List());
    socket.add(payload);
    await socket.flush();
  }

  static Future<Uint8List> _read(StreamIterator<List<int>> it) async {
    final header = <int>[];
    while (header.length < 4) {
      if (!await it.moveNext()) throw const SocketException('Connection closed');
      header.addAll(it.current);
    }
    final length = ByteData.sublistView(Uint8List.fromList(header.take(4).toList())).getUint32(0, Endian.big);
    if (length > maxFrame) throw const FormatException('Frame too large');
    final out = BytesBuilder(copy: false);
    var left = length;
    while (left > 0) {
      if (!await it.moveNext()) throw const SocketException('Connection closed');
      final part = it.current;
      final take = part.length > left ? part.sublist(0, left) : part;
      out.add(take);
      left -= take.length;
    }
    return out.takeBytes();
  }
}
