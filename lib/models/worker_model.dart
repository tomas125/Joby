import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String description;
  final String phone;
  final String email;
  final String category;
  final bool isAvailable;
  final List<String> areaIds;
  final GeoPoint location;

  WorkerModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.phone,
    required this.email,
    required this.category,
    required this.areaIds,
    required this.location,
    this.isAvailable = true,
  });

  factory WorkerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkerModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] is String) 
          ? double.tryParse(data['rating']) ?? 0.0
          : (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      category: data['category'] ?? 'Particular',
      areaIds: List<String>.from(data['areaIds'] ?? []),
      location: data['location'] ?? const GeoPoint(0, 0),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'description': description,
      'phone': phone,
      'email': email,
      'category': category,
      'areaIds': areaIds,
      'location': location,
      'isAvailable': isAvailable,
    };
  }
} 