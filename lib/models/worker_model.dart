class WorkerModel {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final double rating;
  final String description;
  final String phone;
  final String email;
  final String category; // 'Particular' o 'Local'
  final bool isAvailable;
  final String areaId;

  WorkerModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.phone,
    required this.email,
    required this.category,
    required this.areaId,
    this.isAvailable = true,
  });

  factory WorkerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkerModel(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      imageUrl: data['imageUrl'] ?? 'assets/persona2.jpg',
      rating: (data['rating'] is String) 
          ? double.tryParse(data['rating']) ?? 0.0
          : (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      category: data['category'] ?? 'Particular',
      areaId: data['areaId'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'rating': rating,
      'description': description,
      'phone': phone,
      'email': email,
      'category': category,
      'areaId': areaId,
      'isAvailable': isAvailable,
    };
  }
} 