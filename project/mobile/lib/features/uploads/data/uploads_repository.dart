import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';

/// Uploads picked photos to the backend's local-disk-backed /uploads
/// endpoint and returns their absolute URLs. See UploadsController on the
/// backend for how to swap this for real S3 storage later — the mobile
/// side wouldn't need to change at all, since it just receives URLs back.
class UploadsRepository {
  final Dio _dio;
  UploadsRepository(this._dio);

  Future<List<String>> uploadImages(List<XFile> files) async {
    if (files.isEmpty) return const [];
    final multipartFiles = await Future.wait(files.map((f) async {
      final bytes = await f.readAsBytes();
      return MultipartFile.fromBytes(bytes, filename: f.name);
    }));
    final res = await _dio.post(
      '/uploads',
      data: FormData.fromMap({'files': multipartFiles}),
    );
    return (res.data['urls'] as List).cast<String>();
  }
}

final uploadsRepositoryProvider = Provider<UploadsRepository>((ref) {
  return UploadsRepository(ref.read(dioProvider));
});
