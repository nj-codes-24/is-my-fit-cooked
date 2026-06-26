import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minio/minio.dart';
import 'package:uuid/uuid.dart';

/// Provider for the [StorageService].
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Service for compressing images and uploading to Cloudflare R2.
class StorageService {
  StorageService() {
    if (isConfigured) {
      _minio = Minio(
        endPoint: _endPoint,
        accessKey: _accessKey,
        secretKey: _secretKey,
        region: 'auto',
      );
    }
  }

  Minio? _minio;

  static const String _accountId = String.fromEnvironment('R2_ACCOUNT_ID');
  static const String _accessKey = String.fromEnvironment('R2_ACCESS_KEY');
  static const String _secretKey = String.fromEnvironment('R2_SECRET_KEY');
  static const String _bucketName = String.fromEnvironment('R2_BUCKET_NAME');
  
  /// Base URL where uploaded images can be publicly accessed.
  static const String _publicUrl = String.fromEnvironment('R2_PUBLIC_URL');

  static String get _endPoint => '$_accountId.r2.cloudflarestorage.com';

  /// Validates that R2 credentials have been provided.
  bool get isConfigured =>
      _accountId.isNotEmpty &&
      _accessKey.isNotEmpty &&
      _secretKey.isNotEmpty &&
      _bucketName.isNotEmpty &&
      _publicUrl.isNotEmpty;

  /// Compresses the image and uploads it to Cloudflare R2.
  /// Returns the public URL of the uploaded image.
  Future<String> uploadImage(Uint8List imageBytes) async {
    if (!isConfigured || _minio == null) {
      throw Exception(
        'R2 credentials not fully configured. '
        'Provide R2_ACCOUNT_ID, R2_ACCESS_KEY, R2_SECRET_KEY, R2_BUCKET_NAME, and R2_PUBLIC_URL via --dart-define.',
      );
    }

    // 1. Compress image in the background
    final compressedBytes = await compute(_compressImage, imageBytes);

    // 2. Generate unique filename
    final fileName = '${const Uuid().v4()}.jpg';

    // 3. Upload to R2
    final stream = Stream.value(compressedBytes);
    await _minio!.putObject(
      _bucketName,
      fileName,
      stream,
      size: compressedBytes.length,
      metadata: {'Content-Type': 'image/jpeg'},
    );

    // 4. Return public URL
    // Assumes _publicUrl does not end with a slash, e.g., https://cdn.domain.com
    return '$_publicUrl/$fileName';
  }

  /// Top-level function to compress image (for `compute`).
  static Future<Uint8List> _compressImage(Uint8List list) async {
    final result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1024,
      minWidth: 1024,
      quality: 80,
    );
    return result;
  }
}
