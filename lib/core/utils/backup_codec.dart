import 'dart:convert';
import 'dart:typed_data';

/// Codec untuk format cadangan custom aman armada aplikasi faishal.id.
///
/// Format: `FSBK1#<APP_TAG>#<CHECKSUM_HEX>#<BASE64_OBFUSCATED_PAYLOAD>`
///
/// Mencegah manipulasi manual/edit langsung (§VAL):
/// 1. Payload disamarkan menggunakan XOR mask berbasis key unik aplikasi & posisi byte.
/// 2. Integritas data dijaga oleh checksum CRC-32 berbasis salt unik.
/// 3. Setiap perubahan karakter/byte akan menyebabkan verifikasi gagal.
/// 4. Mencegah pemulihan silang antar-aplikasi.
/// 5. Menolak input JSON mentah secara tegas untuk mencegah pengubahan teks manual.
class FleetBackupCodec {
  static const String prefix = 'FSBK1';

  static final List<int> _crcTable = List<int>.generate(256, (i) {
    int c = i;
    for (int k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
    }
    return c;
  });

  static int _computeChecksum(List<int> bytes, String appTag) {
    final salt = utf8.encode('faishal_salt_${appTag.toUpperCase()}');
    int crc = 0xFFFFFFFF;
    for (final b in bytes) {
      crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >>> 8);
    }
    for (final b in salt) {
      crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >>> 8);
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  static Uint8List _maskBytes(List<int> bytes, String appTag) {
    final key = utf8.encode('faishal.id-secure-backup-${appTag.toUpperCase()}');
    final out = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      out[i] = bytes[i] ^ key[i % key.length] ^ ((i * 7 + 0x5A) & 0xFF);
    }
    return out;
  }

  /// Mengubah data map menjadi string cadangan custom yang terproteksi.
  static String encode({
    required String appTag,
    required Map<String, dynamic> data,
  }) {
    final tag = appTag.trim().toUpperCase();
    final jsonStr = jsonEncode(data);
    final rawBytes = utf8.encode(jsonStr);
    final checksum = _computeChecksum(rawBytes, tag).toRadixString(16).padLeft(8, '0');
    final masked = _maskBytes(rawBytes, tag);
    final b64 = base64Encode(masked);
    return '$prefix#$tag#$checksum#$b64';
  }

  /// Membaca dan memverifikasi string cadangan custom.
  /// Melempar [FormatException] bila format tidak valid, aplikasi tidak cocok,
  /// data dimodifikasi (checksum mismatch), atau jika input berupa JSON mentah.
  static Map<String, dynamic> decode({
    required String appTag,
    required String encoded,
  }) {
    final trimmed = encoded.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Data cadangan kosong.');
    }
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      throw const FormatException(
        'Format JSON mentah tidak didukung untuk mencegah manipulasi data. '
        'Gunakan berkas atau kode cadangan resmi.',
      );
    }

    final parts = trimmed.split('#');
    if (parts.length != 4 || parts[0] != prefix) {
      throw const FormatException('Format berkas cadangan tidak valid atau tidak dikenali.');
    }

    final incomingTag = parts[1].trim().toUpperCase();
    final expectedTag = appTag.trim().toUpperCase();
    if (incomingTag != expectedTag) {
      throw FormatException(
        'Berkas cadangan ini milik aplikasi $incomingTag, '
        'tidak dapat dipulihkan ke $expectedTag.',
      );
    }

    final expectedChecksum = parts[2].trim().toLowerCase();
    final List<int> masked;
    try {
      masked = base64Decode(parts[3].trim());
    } catch (_) {
      throw const FormatException('Data cadangan rusak atau format encoding tidak sah.');
    }

    final rawBytes = _maskBytes(masked, incomingTag);
    final actualChecksum = _computeChecksum(rawBytes, incomingTag).toRadixString(16).padLeft(8, '0');

    if (actualChecksum != expectedChecksum) {
      throw const FormatException(
        'Integritas data cadangan tidak valid: data telah dimodifikasi atau rusak.',
      );
    }

    try {
      final decodedJson = jsonDecode(utf8.decode(rawBytes));
      if (decodedJson is! Map<String, dynamic>) {
        throw const FormatException('Isi data cadangan bukan objek data yang sah.');
      }
      return decodedJson;
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Gagal memproses struktur data cadangan: $e');
    }
  }
}
