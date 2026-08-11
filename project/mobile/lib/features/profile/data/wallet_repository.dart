import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class WalletEntry {
  final String type;
  final double amount;
  final String note;
  final DateTime createdAt;

  const WalletEntry({
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  factory WalletEntry.fromJson(Map<String, dynamic> json) => WalletEntry(
        type: json['type'] as String,
        amount: double.parse(json['amount'].toString()),
        note: json['note'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class WalletRepository {
  final Dio _dio;
  WalletRepository(this._dio);

  Future<double> balance() async {
    final res = await _dio.get('/wallet/balance');
    return double.parse(res.data['balance'].toString());
  }

  Future<List<WalletEntry>> history() async {
    final res = await _dio.get('/wallet/history');
    return (res.data as List).map((e) => WalletEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(dioProvider));
});

final walletBalanceProvider = FutureProvider.autoDispose<double>((ref) {
  return ref.read(walletRepositoryProvider).balance();
});
