import 'dart:io';
import 'package:path/path.dart' as p;

class PathSecurity {
  static String sanitizeFileName(String value) {
    var s = value.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_').trim();
    s = s.replaceAll(RegExp(r'[. ]+$'), '');
    if (s.isEmpty) s = 'unnamed';
    const reserved = {
      'CON','PRN','AUX','NUL',
      'COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8','COM9',
      'LPT1','LPT2','LPT3','LPT4','LPT5','LPT6','LPT7','LPT8','LPT9'
    };
    final stem = s.split('.').first.toUpperCase();
    if (reserved.contains(stem)) s = '_$s';
    return s;
  }

  static String safeChild(String root, String relative) {
    if (p.isAbsolute(relative)) {
      throw const FormatException('Absolute paths are not allowed');
    }
    final parts = p.split(relative);
    if (parts.any((x) => x == '..' || x.isEmpty)) {
      throw const FormatException('Unsafe path');
    }
    final cleaned = parts.map(sanitizeFileName).join(p.separator);
    final rootAbs = p.normalize(p.absolute(root));
    final target = p.normalize(p.join(rootAbs, cleaned));
    if (target != rootAbs && !p.isWithin(rootAbs, target)) {
      throw const FormatException('Path escapes receive directory');
    }
    return target;
  }

  static Future<void> ensureRoot(String root) async {
    final dir = Directory(root);
    await dir.create(recursive: true);
  }
}
