import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/rental_models.dart';

class RentalsRepository {
  final Dio _dio;
  RentalsRepository(this._dio);

  Future<List<RentalVehicle>> search({
    String? city,
    String? make,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? transmission,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    final res = await _dio.get('/rentals', queryParameters: {
      if (city != null && city.isNotEmpty) 'city': city,
      if (make != null && make.isNotEmpty) 'make': make,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (category != null) 'category': category,
      if (transmission != null) 'transmission': transmission,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (sortBy != null) 'sortBy': sortBy,
      'page': 1,
      'limit': 20,
    });
    return (res.data['items'] as List)
        .map((e) => RentalVehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RentalVehicle> getById(String id) async {
    final res = await _dio.get('/rentals/$id');
    return RentalVehicle.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RentalVehicle> create(RentalVehicle vehicle) async {
    final res = await _dio.post('/rentals', data: vehicle.toCreateJson());
    return RentalVehicle.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<RentalVehicle>> myVehicles() async {
    final res = await _dio.get('/rentals/mine');
    return (res.data as List)
        .map((e) => RentalVehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    bool withDriver = false,
  }) async {
    final res = await _dio.post('/bookings', data: {
      'vehicleId': vehicleId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'withDriver': withDriver,
    });
    return Booking.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Booking>> myBookings() async {
    final res = await _dio.get('/bookings/mine');
    return (res.data as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> getBooking(String id) async {
    final res = await _dio.get('/bookings/$id');
    return Booking.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> cancelBooking(String id, {String? reason}) async {
    await _dio.patch('/bookings/$id/cancel', data: {if (reason != null) 'reason': reason});
  }
}

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return RentalsRepository(ref.read(dioProvider));
});
