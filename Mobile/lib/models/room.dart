class Room {
  final String id;
  final String title;
  final String? description;
  final String city;
  final String? locality;
  final num rent;
  final num deposit;
  final DateTime? availableFrom;
  final String roomType;
  final String furnishing;
  final String bathroom;
  final bool foodIncluded;
  final String foodType;
  final String genderPreference;
  final bool bachelorsAllowed;
  final bool nearMetro;
  final List<String> images;
  final dynamic ownerId;

  Room({
    required this.id,
    required this.title,
    this.description,
    required this.city,
    this.locality,
    required this.rent,
    required this.deposit,
    this.availableFrom,
    required this.roomType,
    required this.furnishing,
    required this.bathroom,
    required this.foodIncluded,
    required this.foodType,
    required this.genderPreference,
    required this.bachelorsAllowed,
    required this.nearMetro,
    required this.images,
    this.ownerId,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      city: json['city'] ?? '',
      locality: json['locality'],
      rent: json['rent'] ?? 0,
      deposit: json['deposit'] ?? 0,
      availableFrom: json['availableFrom'] != null ? DateTime.tryParse(json['availableFrom']) : null,
      roomType: json['roomType'] ?? 'single',
      furnishing: json['furnishing'] ?? 'unfurnished',
      bathroom: json['bathroom'] ?? 'shared',
      foodIncluded: json['foodIncluded'] ?? false,
      foodType: json['foodType'] ?? 'veg',
      genderPreference: json['genderPreference'] ?? 'any',
      bachelorsAllowed: json['bachelorsAllowed'] ?? true,
      nearMetro: json['nearMetro'] ?? false,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      ownerId: json['ownerId'],
    );
  }
}
