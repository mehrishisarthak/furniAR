import 'package:ar_shopping_app/model/ar_view_screen.dart';
import 'package:ar_shopping_app/model/product_data.dart';
import 'package:ar_shopping_app/model/web_view.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // CHANGED: Using a CustomScrollView for a more dynamic app bar
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Hero(
                // CHANGED: Added Hero widget to enable animation
                tag: 'product_image_${product.name}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  // Loading indicator for a better user experience
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Product Info Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // --- Description Section ---
                  Text(
                    'Description',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      height: 1.5, // Improved line spacing
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Action Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.threed_rotation,
                          label: 'View in 3D',
                          color: Colors.blue.shade700,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product3DViewer(product: product),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.view_in_ar,
                          label: 'View in AR',
                          color: theme.primaryColor,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ARShoppingScreen(productToView: product),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Add to Cart',
                      color: Colors.green.shade700,
                      isPrimary: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: A reusable helper widget for creating styled action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: isPrimary ? 24 : 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isPrimary ? 16 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: isPrimary ? 18 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}