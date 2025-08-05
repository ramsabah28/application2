class CartModel {
  final String name;
  final String description;
  final String category;
  final String brand;
  final double price;
  final int count;
  final String imageUrl;

  const CartModel({
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.count,
    required this.price,
    required this.imageUrl

  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(name: json['name'],
        description: json['description'],
        category: json['category'],
        brand: json['brand'],
        count: json['count'],
        price: json['price'],
        imageUrl: json['imageUrl']);
  }

}