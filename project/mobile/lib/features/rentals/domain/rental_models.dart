class RentalVehicle {
  final String id;
  final String ownerId;
  final String make;
  final String model;
  final int year;
  final String transmission;
  final String fuelType;
  final String city;
  final String pickupLocation;
  final double dailyRate;
  final double securityDeposit;
  final bool driverAvailable;
  final List<String> photoUrls;
  final String? description;
  final String status;
  final String category;
  final int seats;
  final int doors;
  final List<String> features;

  const RentalVehicle({
    required this.id,
    this.ownerId = '',
    required this.make,
    required this.model,
    required this.year,
    required this.transmission,
    required this.fuelType,
    required this.city,
    required this.pickupLocation,
    required this.dailyRate,
    required this.securityDeposit,
    required this.driverAvailable,
    required this.photoUrls,
    this.description,
    this.status = 'pending',
    this.category = 'sedan',
    this.seats = 5,
    this.doors = 4,
    this.features = const [],
  });

  String get title => '$make $model $year';

  factory RentalVehicle.fromJson(Map<String, dynamic> json) => RentalVehicle(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String? ?? (json['owner'] is Map ? json['owner']['id'] as String? : null) ?? '',
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        transmission: json['transmission'] as String,
        fuelType: json['fuelType'] as String,
        city: json['city'] as String,
        pickupLocation: json['pickupLocation'] as String? ?? '',
        dailyRate: double.parse(json['dailyRate'].toString()),
        securityDeposit: double.parse((json['securityDeposit'] ?? 0).toString()),
        driverAvailable: json['driverAvailable'] as bool? ?? false,
        photoUrls: (json['photoUrls'] as List?)?.cast<String>() ?? const [],
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'pending',
        category: json['category'] as String? ?? 'sedan',
        seats: json['seats'] as int? ?? 5,
        doors: json['doors'] as int? ?? 4,
        features: (json['features'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toCreateJson() => {
        'make': make,
        'model': model,
        'year': year,
        'transmission': transmission,
        'fuelType': fuelType,
        'category': category,
        'city': city,
        'pickupLocation': pickupLocation,
        'dailyRate': dailyRate,
        'securityDeposit': securityDeposit,
        'driverAvailable': driverAvailable,
        if (photoUrls.isNotEmpty) 'photoUrls': photoUrls,
        if (description != null) 'description': description,
      };
}

class Booking {
  final String id;
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double securityDeposit;
  final bool withDriver;
  final String status;
  final RentalVehicle? vehicle;

  const Booking({
    required this.id,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.securityDeposit,
    required this.withDriver,
    required this.status,
    this.vehicle,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        totalPrice: double.parse(json['totalPrice'].toString()),
        securityDeposit: double.parse((json['securityDeposit'] ?? 0).toString()),
        withDriver: json['withDriver'] as bool? ?? false,
        status: json['status'] as String,
        vehicle: json['vehicle'] != null
            ? RentalVehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
            : null,
      );
}
