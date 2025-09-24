// lib/screens/ar_shopping_screen.dart

import 'dart:io';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_shopping_app/model/product_data.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARShoppingScreen extends StatefulWidget {
  final Product productToView;
  const ARShoppingScreen({super.key, required this.productToView});

  @override
  State<ARShoppingScreen> createState() => _ARShoppingScreenState();
}

class _ARShoppingScreenState extends State<ARShoppingScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  Product? selectedProduct;
  ARNode? placedNode;
  ARAnchor? placedAnchor;

  double _currentScale = 1.0;
  double _currentRotation = 0.0;
  bool _isARInitialized = false;

  @override
  void initState() {
    super.initState();
    selectedProduct = widget.productToView;
  }

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR View: ${selectedProduct?.name}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
          ),
          if (!_isARInitialized)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Initializing AR...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait while we set up the AR experience.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildUIControls(),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager, ARAnchorManager anchorManager, ARLocationManager? locationManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    try {
      arSessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: true,
        showWorldOrigin: false,
        handleTaps: true,
      );
      arObjectManager!.onInitialize();
      arSessionManager!.onPlaneOrPointTap = _onPlaneOrPointTapped;

      setState(() {
        _isARInitialized = true;
      });

      debugPrint('AR initialization successful');
    } catch (e) {
      debugPrint('AR initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AR initialization failed: $e')),
      );
    }
  }

  Future<String> _copyAssetToTempDirectory(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );

    debugPrint("Copied asset to: ${tempFile.path}");
    return tempFile.path;
  }

  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitResults) async {
    if (selectedProduct == null ||
        placedNode != null ||
        arAnchorManager == null ||
        arObjectManager == null ||
        arSessionManager == null) {
      return;
    }

    var planeHits = hitResults
        .where((hit) => hit.type == ARHitTestResultType.plane)
        .toList();

    if (planeHits.isEmpty) {
      debugPrint('No plane hits detected');
      return;
    }

    debugPrint(
        'Plane hit detected, attempting to place ${selectedProduct!.name}');

    try {
      var singleHit = planeHits.first;
      var newAnchor =
          ARPlaneAnchor(transformation: singleHit.worldTransform);

      debugPrint('Adding anchor...');
      bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);

      if (didAddAnchor != true) {
        debugPrint('Failed to add anchor');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add anchor")),
        );
        return;
      }

      debugPrint(
          'Anchor added successfully, creating node for: ${selectedProduct!.assetPath}');
      final tempPath =
          await _copyAssetToTempDirectory(selectedProduct!.assetPath);

      var newNode = ARNode(
        type: NodeType.fileSystemAppFolderGLTF2,
        uri: tempPath,
        scale:
            vector.Vector3.all(_currentScale * selectedProduct!.scale.x),
        position: vector.Vector3(0, 0, 0),
        rotation: vector.Vector4(0, 0, 0, 1),
      );

      debugPrint('Attempting to add node with URI: ${newNode.uri}');

      bool? didAddNode = await arObjectManager!.addNode(
        newNode,
        planeAnchor: newAnchor,
      );

      if (didAddNode == true) {
        debugPrint('Node added successfully!');
        setState(() {
          placedNode = newNode;
          placedAnchor = newAnchor;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${selectedProduct!.name} placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint('addNode returned false for ${newNode.uri}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load ${selectedProduct!.name} model')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error placing object: $e');
      debugPrint('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildUIControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (placedNode == null) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(77)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.touch_app,
                    size: 32,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isARInitialized
                        ? "Move your phone to scan the floor, then tap the grid to place ${selectedProduct?.name}"
                        : "Initializing AR...",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.widgets, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  "${selectedProduct?.name} Placed!",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildScaleSlider(),
            const SizedBox(height: 8),
            buildRotationSlider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Remove"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _onRemoveButtonPressed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Replace"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _onReplaceButtonPressed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildScaleSlider() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.photo_size_select_large, size: 20),
            const SizedBox(width: 8),
            Text(
              "Size: ${(_currentScale * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.zoom_out),
            Expanded(
              child: Slider(
                value: _currentScale,
                min: 0.1,
                max: 2.0,
                divisions: 19,
                activeColor: Colors.deepPurple,
                onChanged: (value) {
                  setState(() {
                    _currentScale = value;
                    _updateNodeTransform();
                  });
                },
              ),
            ),
            const Icon(Icons.zoom_in),
          ],
        ),
      ],
    );
  }

  Widget buildRotationSlider() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.screen_rotation_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              "Rotation: ${(_currentRotation * 180 / 3.14).toStringAsFixed(0)}°",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.rotate_left),
            Expanded(
              child: Slider(
                value: _currentRotation,
                min: -3.14,
                max: 3.14,
                divisions: 100,
                activeColor: Colors.deepPurple,
                onChanged: (value) {
                  setState(() {
                    _currentRotation = value;
                    _updateNodeTransform();
                  });
                },
              ),
            ),
            const Icon(Icons.rotate_right),
          ],
        ),
      ],
    );
  }

  void _updateNodeTransform() {
    if (placedNode != null && selectedProduct != null) {
      placedNode!.transform = vector.Matrix4.identity()
        ..scale(vector.Vector3.all(
            _currentScale * selectedProduct!.scale.x))
        ..rotateY(_currentRotation);
    }
  }

  Future<void> _onRemoveButtonPressed() async {
    if (placedNode != null &&
        placedAnchor != null &&
        arObjectManager != null &&
        arAnchorManager != null) {
      try {
        await arObjectManager!.removeNode(placedNode!);
        await arAnchorManager!.removeAnchor(placedAnchor!);

        setState(() {
          placedNode = null;
          placedAnchor = null;
          _currentScale = 1.0;
          _currentRotation = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Object removed'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        debugPrint('Error removing object: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error removing object: $e")),
        );
      }
    }
  }

  void _onReplaceButtonPressed() {
    setState(() {
      placedNode = null;
      placedAnchor = null;
      _currentScale = 1.0;
      _currentRotation = 0.0;
    });
  }
}
