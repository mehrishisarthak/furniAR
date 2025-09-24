import 'package:ar_shopping_app/model/product_data.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

final List<Product> products = [
  Product(
    name: "Modern Bed",
    imageUrl: "https://m.media-amazon.com/images/I/81dZCYofVcL.jpg",
    assetPath: "assets/models/bed.glb",
    sketchfabUrl: "https://sketchfab.com/models/8f6c2a5ccffc459aac826ca7ee0a28c6/embed?autostart=1&ui_theme=dark",
    scale: vector.Vector3(0.4, 0.4, 0.4),
    description: "Comfortable modern bed with sleek design and a sturdy wooden frame. Perfect for a contemporary bedroom.",
    price: 899.99,
  ),
  Product(
    name: "Dining Table",
    imageUrl: "https://m.media-amazon.com/images/I/91sGuTqHYPL.jpg",
    assetPath: "assets/models/table.glb", 
    sketchfabUrl: "https://sketchfab.com/models/9e3c5885a19a48708b3c83c969879921/embed?autostart=1&ui_theme=dark",
    scale: vector.Vector3(0.5, 0.5, 0.5),
    description: "Elegant wooden dining table for family meals. Seats up to six people comfortably.",
    price: 549.99,
  ),
  Product(
    name: "Luxury Sofa",
    imageUrl: "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=2940",
    assetPath: "assets/models/sofa.glb",
    sketchfabUrl: "https://sketchfab.com/models/f52dc897890c49ee906cc4b3d31e614e/embed?autostart=1&ui_theme=dark",
    scale: vector.Vector3(0.3, 0.3, 0.3),
    description: "Premium leather sofa with cushioned comfort and a timeless, classic aesthetic.",
    price: 1299.99,
  ),
  Product(
    name: "Designer Lamp",
    imageUrl: "https://images.unsplash.com/photo-1543198126-a8ad8e47fb22?q=80&w=2853",
    assetPath: "assets/models/lamp.glb",
    sketchfabUrl: "https://sketchfab.com/models/34a6c71f784846a6a2904e94d9ae0e39/embed?autostart=1&ui_theme=dark",
    scale: vector.Vector3(0.8, 0.8, 0.8),
    description: "Modern LED desk lamp with adjustable brightness and a minimalist metal finish.",
    price: 149.99,
  ),
  Product(
    name: "Wooden Box",
    imageUrl: "https://media.istockphoto.com/id/613676712/photo/cube-on-white-background-3d-illustration.jpg?s=612x612&w=0&k=20&c=5EWj5XjxE1wrUPG_OoXbxkqIRCNz-02HoEReJaGIhYo=",
    assetPath: "assets/models/Box.glb",
    sketchfabUrl: "https://sketchfab.com/models/91f2848af1724aff9e713ffd3404e840/embed?autostart=1&ui_theme=dark",
    scale: vector.Vector3(0.8, 0.8, 0.8),
    description: "A simple and elegant wooden box for storage and decoration. Perfect for testing.",
    price: 99.99,
  ),
  Product(
    name: "Rubber Duck",
    imageUrl: "https://cdn11.bigcommerce.com/s-nf2x4/images/stencil/1280x1280/products/884/9637/Turquoise-Blue-Rubber-Duck-Adline-7__79869.1668806323.jpg?c=2",
    assetPath: "assets/models/Duck.glb",
    sketchfabUrl: "https://sketchfab.com/models/c5739cd7a94547dcb091bdd527536977/embed?autostart=1&ui_theme=dark",
    scale: vector.Vector3(0.4, 0.4, 0.4),
    description: "A classic rubber ducky model for testing AR functionality and bringing joy.",
    price: 9.99, // Adjusted price
  ),
];