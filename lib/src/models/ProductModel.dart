class ProductModel {
  final String uuid;
  final String name;
  final String description;
  final String midDescription;
  final String longDiscription;
  final String category;
  final String brand;
  final double price;
  final int count;
  final String imageUrl;
  final List<dynamic> images; // raw list from Firestore: [{color, url}, ...]

  const ProductModel({
    required this.uuid,
    required this.name,
    required this.description,
    required this.midDescription,
    required this.longDiscription,
    required this.category,
    required this.brand,
    required this.count,
    required this.price,
    required this.imageUrl,
    this.images = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    String derivedImageUrl = '';
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map && first['url'] != null) {
        derivedImageUrl = first['url'].toString();
      }
    }

    return ProductModel(
      uuid: (json['uuid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      midDescription: (json['midDescription'] ?? '').toString(),
      longDiscription: (json['longDescription'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['imageUrl'] ?? derivedImageUrl).toString(),
      images: images is List ? images : const [],
    );
  }
}
