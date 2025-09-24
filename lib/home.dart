import 'package:ar_shopping_app/model/product_data.dart';
import 'package:ar_shopping_app/product_details.dart';
import 'package:flutter/material.dart';

class ShoppingAppHomeScreen extends StatelessWidget {
  final List<Product> products;
  const ShoppingAppHomeScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Slightly lighter background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            elevation: 4, // Added subtle elevation
            shadowColor: Colors.black.withAlpha(50), // Softer shadow
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], // Richer purple
                ),
              ),
              child: const FlexibleSpaceBar(
                title: Text(
                  '🪑 FurniAR Store',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20, // Slightly larger title
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: true,
                titlePadding: EdgeInsets.only(bottom: 16),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 26),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // NEW: Title for the product grid
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8, // Adjusted for better card proportions
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  // REFACTORED: Using the new ProductCard widget
                  return ProductCard(product: product);
                },
                childCount: products.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }
}

// NEW WIDGET: A reusable card for displaying a product
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Hero Animation
            Expanded(
              child: Stack(
                children: [
                  // NEW: Using Hero widget for animation
                  Hero(
                    tag: 'product_image_${product.name}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      // NEW: Using Image.network instead of an icon
                      child: Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        // Loading indicator for network images
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        // Error placeholder
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.image_not_supported));
                        },
                      ),
                    ),
                  ),
                  // NEW: Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          // Add favorite logic here
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}