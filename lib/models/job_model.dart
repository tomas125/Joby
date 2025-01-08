import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String userId;
  final String workerId;
  bool done;
  String description;
  final DateTime createdAt;
  DateTime updatedAt;

  JobModel({
    required this.id,
    required this.userId,
    required this.workerId,
    this.done = false,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workerId': workerId,
      'done': done,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory JobModel.fromMap(String id, Map<String, dynamic> map) {
    return JobModel(
      id: id,
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      done: map['done'] ?? false,
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
} 