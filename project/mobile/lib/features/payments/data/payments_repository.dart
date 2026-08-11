import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

/// Mirrors the backend's PaymentGateway enum. CASH_ON_PICKUP and CARD are
/// both fully mocked here (no real JazzCash/Easypaisa/card processor is
/// wired up) — see PaymentsService on the backend for the integration notes.
enum PaymentMethod { cashOnPickup, mockCard }

extension on PaymentMethod {
  String get gatewayValue => switch (this) {
        PaymentMethod.cashOnPickup => 'cash_on_pickup',
        PaymentMethod.mockCard => 'card',
      };
}

class PaymentsRepository {
  final Dio _dio;
  PaymentsRepository(this._dio);

  Future<String> initiate({
    required double amount,
    required PaymentMethod method,
    required String relatedBookingId,
  }) async {
    final res = await _dio.post('/payments/initiate', data: {
      'amount': amount,
      'gateway': method.gatewayValue,
      'relatedBookingId': relatedBookingId,
    });
    return res.data['orderId'] as String;
  }

  /// Dev-only settlement endpoint that simulates the gateway webhook —
  /// see PaymentsController on the backend.
  Future<void> devSettle(String orderId, {required bool success, String? ownerId}) async {
    await _dio.post('/payments/$orderId/dev-settle', data: {
      'success': success,
      if (ownerId != null) 'ownerId': ownerId,
    });
  }
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.read(dioProvider));
});
