class CarListing {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? variant;
  final int mileageKm;
  final double price;
  final String city;
  final String transmission;
  final String fuelType;
  final List<String> photoUrls;
  final String? description;
  final bool isVerified;
  final String status;
  final String category;
  final int seats;
  final int doors;
  final List<String> features;
  final String? sellerId;

  const CarListing({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.variant,
    required this.mileageKm,
    required this.price,
    required this.city,
    required this.transmission,
    required this.fuelType,
    required this.photoUrls,
    this.description,
    required this.isVerified,
    required this.status,
    this.category = 'sedan',
    this.seats = 5,
    this.doors = 4,
    this.features = const [],
    this.sellerId,
  });

  String get title => '$make $model $year';

  factory CarListing.fromJson(Map<String, dynamic> json) => CarListing(
        id: json['id'] as String,
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        variant: json['variant'] as String?,
        mileageKm: json['mileageKm'] as int,
        price: double.parse(json['price'].toString()),
        city: json['city'] as String,
        transmission: json['transmission'] as String,
        fuelType: json['fuelType'] as String,
        photoUrls: (json['photoUrls'] as List?)?.cast<String>() ?? const [],
        description: json['description'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        status: json['status'] as String? ?? 'pending',
        category: json['category'] as String? ?? 'sedan',
        seats: json['seats'] as int? ?? 5,
        doors: json['doors'] as int? ?? 4,
        features: (json['features'] as List?)?.cast<String>() ?? const [],
        sellerId: json['sellerId'] as String? ?? (json['seller'] is Map ? json['seller']['id'] as String? : null),
      );

  Map<String, dynamic> toCreateJson() => {
        'make': make,
        'model': model,
        'year': year,
        if (variant != null) 'variant': variant,
        'mileageKm': mileageKm,
        'price': price,
        'city': city,
        'transmission': transmission,
        'fuelType': fuelType,
        'category': category,
        if (photoUrls.isNotEmpty) 'photoUrls': photoUrls,
        if (description != null) 'description': description,
      };
}
