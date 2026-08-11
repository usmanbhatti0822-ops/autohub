import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/listings_repository.dart';
import '../../domain/car_listing.dart';

class ListingFilters {
  final String? make;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String? category;
  final String? transmission;
  final String? fuelType;
  final String? sortBy;

  const ListingFilters({
    this.make,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.category,
    this.transmission,
    this.fuelType,
    this.sortBy,
  });

  bool get isActive =>
      city != null || minPrice != null || maxPrice != null || category != null || transmission != null || fuelType != null;

  ListingFilters copyWith({
    String? make,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? transmission,
    String? fuelType,
    String? sortBy,
  }) =>
      ListingFilters(
        make: make ?? this.make,
        city: city ?? this.city,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        category: category ?? this.category,
        transmission: transmission ?? this.transmission,
        fuelType: fuelType ?? this.fuelType,
        sortBy: sortBy ?? this.sortBy,
      );
}

final listingFiltersProvider =
    StateProvider<ListingFilters>((ref) => const ListingFilters());

final listingsProvider = FutureProvider.autoDispose<List<CarListing>>((ref) {
  final repo = ref.read(listingsRepositoryProvider);
  final filters = ref.watch(listingFiltersProvider);
  return repo.search(
    make: filters.make,
    city: filters.city,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    category: filters.category,
    transmission: filters.transmission,
    fuelType: filters.fuelType,
    sortBy: filters.sortBy,
  );
});

final listingDetailProvider =
    FutureProvider.autoDispose.family<CarListing, String>((ref, id) {
  final repo = ref.read(listingsRepositoryProvider);
  return repo.getById(id);
});
