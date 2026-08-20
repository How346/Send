import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FrameReader {
  FrameReader(Stream<List<int>> stream)
      : _iterator = StreamIterator<List<int>>(stream);

  final StreamIterator<List<int>> _iterator;
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  bool _closed = false;

  Future<void> _fill(int count) async {
    while (_buffer.length < count) {
      if (!await _iterator.moveNext()) {
        _closed = true;
        throw const SocketException('Connection closed');
      }

      _buffer.add(_iterator.current);
    }
  }

  Future<Uint8List> readFrame() async {
    if (_closed) {
      throw const SocketException('Connection closed');
    }

    await _fill(4);

    final header = _buffer.takeBytes();

    final length = ByteData.sublistView(header).getUint32(
      0,
      Endian.big,
    );

    if (length > FrameCodec.maxFrame) {
      throw const FormatException('Frame too large');
    }

    if (header.length > 4) {
      _buffer.add(header.sublist(4));
    }

    await _fill(length);

    final data = _buffer.takeBytes();

    if (data.length > length) {
      _buffer.add(data.sublist(length));

      return Uint8List.fromList(
        data.sublist(0, length),
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> readJson() async {
    final bytes = await readFrame();

    final decoded = jsonDecode(
      utf8.decode(bytes),
    );

    if (decoded is! Map) {
      throw const FormatException(
        'Invalid control frame',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<void> close() async {
    await _iterator.cancel();
    _closed = true;
  }
}

class FrameCodec {
  static const int maxFrame = 2 * 1024 * 1024;

  static Future<void> writeJson(
    Socket socket,
    Map<String, dynamic> value,
  ) async {
    final bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(value)),
    );

    await _write(socket, bytes);
  }

  static Future<void> writeBytes(
    Socket socket,
    Uint8List bytes,
  ) async {
    await _write(socket, bytes);
  }

  static Future<void> _write(
    Socket socket,
    Uint8List payload,
  ) async {
    if (payload.length > maxFrame) {
      throw const FormatException(
        'Frame too large',
      );
    }

    final header = ByteData(4)
      ..setUint32(
        0,
        payload.length,
        Endian.big,
      );

    socket.add(
      header.buffer.asUint8List(),
    );

    socket.add(payload);

    await socket.flush();
  }
}
