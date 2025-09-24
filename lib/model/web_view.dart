import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ar_shopping_app/model/product_data.dart';

class Product3DViewer extends StatefulWidget {
  final Product product;
  
  const Product3DViewer({super.key, required this.product});

  @override
  State<Product3DViewer> createState() => _Product3DViewerState();
}

class _Product3DViewerState extends State<Product3DViewer> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.product.sketchfabUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('3D View: ${widget.product.name}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to AR view
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading 3D Model...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          
          // Floating controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230), // Updated
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51), // Updated
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.view_in_ar),
                          label: const Text('View in AR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // Will navigate to AR view
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_cart),
                          label: Text('\$${widget.product.price.toStringAsFixed(0)}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.product.name} added to cart!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}