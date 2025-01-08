class ImageModel {
  final String url;
  final bool isExternalUrl;

  ImageModel({
    required this.url,
    this.isExternalUrl = true,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      url: map['url'] ?? '',
      isExternalUrl: map['isExternalUrl'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'isExternalUrl': isExternalUrl,
    };
  }
} 