import 'dart:convert';
import 'package:uuid/uuid.dart';

void main() {
  var uuid = Uuid();

  var products = List.generate(1000, (i) {

    var images = List.generate(3, (j) => {
      "url": "https://i.otto.de/i/otto/57c6fd67-f0cb-51f6-9f32-0260ab0517f9?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto",
      "color": ["Red", "Blue", "Green", "Black", "White"][j % 5],
    });

    return {
      "uuid": uuid.v4(),
      "name": "Product $i",
      "count": 2,
      "description": "About the product. The product is available.",
      "midDescription": "More Description about the Product.",
      "longDescription":
      "Long Description about the Product containing some specific details about the design and functionality.",
      "category": "category${i % 10}",
      "brand": "Brand${i % 5}",
      "price": (10 + i).toDouble(),
      "imageUrl":
      "https://i.otto.de/i/otto/57c6fd67-f0cb-51f6-9f32-0260ab0517f9?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto",
      "images": images,
    };
  });

  print(jsonEncode(products));
}
