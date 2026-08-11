import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<String?> requestOtp(String phone) async {
    final res = await _dio.post('/auth/otp/request', data: {'phone': phone});
    // devCode is only present outside production — handy for testing.
    return res.data['devCode'] as String?;
  }

  Future<AppUser> verifyOtp(String phone, String code) async {
    final res = await _dio.post(
      '/auth/otp/verify',
      data: {'phone': phone, 'code': code},
    );
    return _persistAndReturn(res.data as Map<String, dynamic>);
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });
    return _persistAndReturn(res.data as Map<String, dynamic>);
  }

  Future<AppUser> login({required String email, required String password}) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _persistAndReturn(res.data as Map<String, dynamic>);
  }

  /// Returns the dev reset code (non-null only outside production) so the
  /// UI can prefill it during testing without a real email service.
  Future<String?> forgotPassword(String email) async {
    final res = await _dio.post('/auth/forgot-password', data: {'email': email});
    return res.data['devCode'] as String?;
  }

  Future<AppUser> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final res = await _dio.post('/auth/reset-password', data: {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
    return _persistAndReturn(res.data as Map<String, dynamic>);
  }

  Future<AppUser> updateProfile({
    String? fullName,
    String? email,
    String? city,
    String? avatarUrl,
  }) async {
    final res = await _dio.patch('/users/me', data: {
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (city != null) 'city': city,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AppUser?> fetchCurrentUser() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    try {
      final res = await _dio.get('/users/me');
      return AppUser.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  Future<AppUser> _persistAndReturn(Map<String, dynamic> data) async {
    final token = data['accessToken'] as String;
    await _storage.write(key: 'access_token', value: token);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(secureStorageProvider));
});
