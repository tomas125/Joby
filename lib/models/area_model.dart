class AreaModel {
  final String id;
  final String name;
  final String icon;
  final String description;

  AreaModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory AreaModel.fromMap(Map<String, dynamic> map, String id) {
    return AreaModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
} 