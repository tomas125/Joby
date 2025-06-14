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
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime? processedAt;
  final DateTime? createdAt;
  final String? document; // CUIL para particulares, CUIT para locales

  WorkerModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.phone,
    required this.email,
    required this.category,
    required this.areaIds,
    required this.location,
    this.rating = 0.0,
    this.isAvailable = true,
    this.status = 'pending',
    this.rejectionReason,
    this.approvedBy,
    this.processedAt,
    this.createdAt,
    this.document,
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
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
      approvedBy: data['approvedBy'],
      processedAt: data['processedAt'] != null 
          ? (data['processedAt'] as Timestamp).toDate() 
          : null,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      document: data['document'],
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
      'status': status,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'document': document,
    };
  }
} 