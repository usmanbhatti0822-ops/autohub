import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/rentals_repository.dart';
import '../../domain/rental_models.dart';

class RentalSearchParams {
  final String? city;
  final String? make;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;
  final String? transmission;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const RentalSearchParams({
    this.city,
    this.make,
    this.startDate,
    this.endDate,
    this.category,
    this.transmission,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  bool get isActive =>
      city != null || category != null || transmission != null || minPrice != null || maxPrice != null;

  RentalSearchParams copyWith({
    String? city,
    String? make,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? transmission,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) =>
      RentalSearchParams(
        city: city ?? this.city,
        make: make ?? this.make,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        category: category ?? this.category,
        transmission: transmission ?? this.transmission,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        sortBy: sortBy ?? this.sortBy,
      );
}

final rentalSearchParamsProvider =
    StateProvider<RentalSearchParams>((ref) => const RentalSearchParams());

final rentalVehiclesProvider =
    FutureProvider.autoDispose<List<RentalVehicle>>((ref) {
  final repo = ref.read(rentalsRepositoryProvider);
  final params = ref.watch(rentalSearchParamsProvider);
  return repo.search(
    city: params.city,
    make: params.make,
    startDate: params.startDate,
    endDate: params.endDate,
    category: params.category,
    transmission: params.transmission,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
    sortBy: params.sortBy,
  );
});

final rentalVehicleDetailProvider =
    FutureProvider.autoDispose.family<RentalVehicle, String>((ref, id) {
  return ref.read(rentalsRepositoryProvider).getById(id);
});

final myBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  return ref.read(rentalsRepositoryProvider).myBookings();
});

final bookingDetailProvider =
    FutureProvider.autoDispose.family<Booking, String>((ref, id) {
  return ref.read(rentalsRepositoryProvider).getBooking(id);
});
