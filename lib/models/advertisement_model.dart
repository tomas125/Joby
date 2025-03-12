class AdvertisementModel {
  final String id;
  final String name;
  final String imageUrl;
  final bool isAvailable;
  final bool isExternalUrl;
  final String? link;
  final String? phoneNumber;

  AdvertisementModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isAvailable = true,
    this.isExternalUrl = false,
    this.link,
    this.phoneNumber,
  });

  factory AdvertisementModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AdvertisementModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      isExternalUrl: data['isExternalUrl'] ?? false,
      link: data['link'],
      phoneNumber: data['phoneNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isExternalUrl': isExternalUrl,
      'link': link,
      'phoneNumber': phoneNumber,
    };
  }
} 