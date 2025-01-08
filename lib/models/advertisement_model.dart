class AdvertisementModel {
  final String id;
  final String name;
  final String imageUrl;
  final bool isAvailable;
  final bool isExternalUrl;

  AdvertisementModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isAvailable = true,
    this.isExternalUrl = false,
  });

  factory AdvertisementModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AdvertisementModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      isExternalUrl: data['isExternalUrl'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isExternalUrl': isExternalUrl,
    };
  }
} 