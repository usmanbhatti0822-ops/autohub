import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/car_listing.dart';

class ListingsRepository {
  final Dio _dio;
  ListingsRepository(this._dio);

  Future<List<CarListing>> search({
    String? make,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? transmission,
    String? fuelType,
    String? sortBy,
    int page = 1,
  }) async {
    final res = await _dio.get('/listings', queryParameters: {
      if (make != null && make.isNotEmpty) 'make': make,
      if (city != null && city.isNotEmpty) 'city': city,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (category != null) 'category': category,
      if (transmission != null) 'transmission': transmission,
      if (fuelType != null) 'fuelType': fuelType,
      if (sortBy != null) 'sortBy': sortBy,
      'page': page,
      'limit': 20,
    });
    final items = (res.data['items'] as List)
        .map((e) => CarListing.fromJson(e as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<CarListing> getById(String id) async {
    final res = await _dio.get('/listings/$id');
    return CarListing.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CarListing> create(CarListing listing) async {
    final res = await _dio.post('/listings', data: listing.toCreateJson());
    return CarListing.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<CarListing>> myListings() async {
    final res = await _dio.get('/listings/mine');
    return (res.data as List)
        .map((e) => CarListing.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(ref.read(dioProvider));
});
