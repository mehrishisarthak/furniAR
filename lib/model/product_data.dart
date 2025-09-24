import 'package:vector_math/vector_math_64.dart' as vector;

class Product {
  final String name;
  final String assetPath;
  final String sketchfabUrl;
  final String imageUrl; // ADD THIS LINE
  final vector.Vector3 scale;
  final String description;
  final double price;

  Product({
    required this.name,
    required this.assetPath,
    required this.sketchfabUrl,
    required this.imageUrl, // ADD THIS LINE
    required this.scale,
    required this.description,
    required this.price,
  });
}