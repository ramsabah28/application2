import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../../firebase_options.dart';

// Main function to run the app directly
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FetchingDataApp());
}

class FetchingDataApp extends StatelessWidget {
  const FetchingDataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Data Entry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FetchingDataUI(),
    );
  }
}

class FetchingDataUI extends StatefulWidget {
  const FetchingDataUI({Key? key}) : super(key: key);

  @override
  State<FetchingDataUI> createState() => _FetchingDataUIState();
}

class _FetchingDataUIState extends State<FetchingDataUI> {
  bool _isLoading = false;

  // Simple form controllers
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _countController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Main image
  final _descriptionController = TextEditingController();
  final _midDescriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  
  // Sub-images controllers (up to 3)
  final _subImage1UrlController = TextEditingController();
  final _subImage1ColorController = TextEditingController();
  final _subImage2UrlController = TextEditingController();
  final _subImage2ColorController = TextEditingController();
  final _subImage3UrlController = TextEditingController();
  final _subImage3ColorController = TextEditingController();

  // Predefined colors
  final List<String> _availableColors = [
    "Red", "Blue", "Green", "Black", "White", 
    "Yellow", "Orange", "Purple", "Pink", "Brown"
  ];

  // Image URL builder variables
  final String _baseUrl = "https://www.silicasoft.de/imagePath/";
  String _selectedFolderNumber = "001";
  String _selectedSubImageNumber = "1";
  String _selectedExtension = "jpg";
  
  // Sub-image URL builder variables
  String _selectedSubImage1FolderNumber = "001";
  String _selectedSubImage1SubNumber = "1";
  String _selectedSubImage1Extension = "jpg";
  
  String _selectedSubImage2FolderNumber = "002";
  String _selectedSubImage2SubNumber = "1";
  String _selectedSubImage2Extension = "jpg";
  
  String _selectedSubImage3FolderNumber = "003";
  String _selectedSubImage3SubNumber = "1";
  String _selectedSubImage3Extension = "jpg";

  // Helper method to build URL
  String _buildImageUrl(String folderNumber, String subNumber, String extension) {
    return "$_baseUrl$folderNumber/$folderNumber-$subNumber.$extension";
  }

  // Update main image URL
  void _updateMainImageUrl() {
    _imageUrlController.text = _buildImageUrl(_selectedFolderNumber, _selectedSubImageNumber, _selectedExtension);
  }

  // Update sub-image URLs
  void _updateSubImage1Url() {
    _subImage1UrlController.text = _buildImageUrl(_selectedSubImage1FolderNumber, _selectedSubImage1SubNumber, _selectedSubImage1Extension);
  }

  void _updateSubImage2Url() {
    _subImage2UrlController.text = _buildImageUrl(_selectedSubImage2FolderNumber, _selectedSubImage2SubNumber, _selectedSubImage2Extension);
  }

  void _updateSubImage3Url() {
    _subImage3UrlController.text = _buildImageUrl(_selectedSubImage3FolderNumber, _selectedSubImage3SubNumber, _selectedSubImage3Extension);
  }

  // Show image preview dialog
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Image Preview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  imageUrl,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.red[50],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Image not found\nor failed to load',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    // Initialize URLs
    _updateMainImageUrl();
    _updateSubImage1Url();
    _updateSubImage2Url();
    _updateSubImage3Url();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase already initialized');
    }
  }

  // Simple function to add product to Firestore
  Future<void> _addProduct() async {
    // Basic validation
    if (_nameController.text.isEmpty) {
      _showMessage('Please enter product name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uuid = Uuid().v4();
      
      // Build images array (sub-images with colors)
      List<Map<String, String>> images = [];
      
      // Add sub-image 1 if provided
      if (_subImage1UrlController.text.isNotEmpty) {
        images.add({
          "url": _subImage1UrlController.text,
          "color": _subImage1ColorController.text.isEmpty ? "Red" : _subImage1ColorController.text,
        });
      }
      
      // Add sub-image 2 if provided
      if (_subImage2UrlController.text.isNotEmpty) {
        images.add({
          "url": _subImage2UrlController.text,
          "color": _subImage2ColorController.text.isEmpty ? "Blue" : _subImage2ColorController.text,
        });
      }
      
      // Add sub-image 3 if provided
      if (_subImage3UrlController.text.isNotEmpty) {
        images.add({
          "url": _subImage3UrlController.text,
          "color": _subImage3ColorController.text.isEmpty ? "Green" : _subImage3ColorController.text,
        });
      }
      
      // If no sub-images provided, add a default one
      if (images.isEmpty) {
        images.add({
          "url": _imageUrlController.text.isEmpty ? "https://via.placeholder.com/300" : _imageUrlController.text,
          "color": "Default"
        });
      }
      
      // Create product with proper structure
      final product = {
        "uuid": uuid,
        "name": _nameController.text.isEmpty ? "Default Product" : _nameController.text,
        "brand": _brandController.text.isEmpty ? "Default Brand" : _brandController.text,
        "price": _priceController.text.isEmpty ? 10.0 : double.tryParse(_priceController.text) ?? 10.0,
        "count": _countController.text.isEmpty ? 1 : int.tryParse(_countController.text) ?? 1,
        "imageUrl": _imageUrlController.text.isEmpty ? "https://via.placeholder.com/300" : _imageUrlController.text,
        "description": _descriptionController.text.isEmpty 
            ? "This is a high-quality ${_brandController.text.isEmpty ? 'Default Brand' : _brandController.text} product from the Models category. Built to deliver performance and durability."
            : _descriptionController.text,
        "midDescription": _midDescriptionController.text.isEmpty
            ? "The ${_nameController.text.isEmpty ? 'Default Product' : _nameController.text} offers reliable performance, designed for daily use with a focus on quality and comfort."
            : _midDescriptionController.text,
        "longDiscription": _longDescriptionController.text.isEmpty
            ? "The ${_nameController.text.isEmpty ? 'Default Product' : _nameController.text} is engineered to meet the highest standards in the Models market. Crafted with attention to detail and equipped with advanced features, it ensures optimal performance, longevity, and user satisfaction."
            : _longDescriptionController.text,
        "category": "Models",
        "images": images, // Array of sub-images with colors
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('product')
          .doc(uuid)
          .set(product);

      _showMessage('✅ Product added successfully with ${images.length} image(s)!');
      _clearFields();
      
    } catch (e) {
      _showMessage('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Generate random products (from original file)
  Future<void> _generateRandomProducts() async {
    setState(() => _isLoading = true);

    try {
      final baseUrl = "https://silicasoft.de/imagePath/";
      final categories = ["Kunst", "Mode", "Schmuck", "Haus", "Models", "Spiele", "Game", "Movie"];
      final filaments = ["PLA", "ABS", "PETG", "TUP", "ASA", "Nylon", "Wood Composite", "Carbon Fiber", "PVA", "Philips"];
      
      var uuidGenerator = Uuid();
      var random = Random();

      for (var i = 1; i <= 2; i++) {
        try {
          final uuid = uuidGenerator.v4();
          final brand = filaments[random.nextInt(filaments.length)];
          final category = categories[random.nextInt(categories.length)];
          final price = (50 + random.nextInt(950)) + random.nextDouble();
          final count = 1 + random.nextInt(20);

          final product = {
            "uuid": uuid,
            "name": "$brand Product $i",
            "count": count,
            "description": "This is a high-quality $brand product from the $category category. Built to deliver performance and durability.",
            "midDescription": "The $brand Product $i offers reliable performance, designed for daily use with a focus on quality and comfort.",
            "longDiscription": "The $brand Product $i is engineered to meet the highest standards in the $category market. Crafted with attention to detail and equipped with advanced features, it ensures optimal performance, longevity, and user satisfaction.",
            "category": "Models",
            "brand": brand,
            "price": double.parse(price.toStringAsFixed(2)),
            "imageUrl": baseUrl + "00$i/00$i-1.jpg",
            "images": List.generate(3, (j) => {
              "url": baseUrl + "00$i/00$i-${j+1}.jpg",
              "color": ["Red", "Blue", "Green", "Black", "White"][j % 5],
            }),
          };

          await FirebaseFirestore.instance.collection('product').doc(uuid).set(product);
          print('✅ Added product #$i: ${product['name']}');
        } catch (e) {
          print('❌ Failed to add product #$i: $e');
        }
      }

      _showMessage('🎉 Random products generated successfully!');
    } catch (e) {
      _showMessage('❌ Error generating products: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _brandController.clear();
    _priceController.clear();
    _countController.clear();
    _imageUrlController.clear();
    _descriptionController.clear();
    _midDescriptionController.clear();
    _longDescriptionController.clear();
    _subImage1UrlController.clear();
    _subImage1ColorController.clear();
    _subImage2UrlController.clear();
    _subImage2ColorController.clear();
    _subImage3UrlController.clear();
    _subImage3ColorController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Product Data'),
        backgroundColor: Colors.black45,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Simple input fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock Count',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Description fields section
            const Divider(),
            const Text(
              'Product Descriptions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                helperText: 'Short product description',
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _midDescriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mid Description',
                border: OutlineInputBorder(),
                helperText: 'Medium length product description',
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _longDescriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Long Description',
                border: OutlineInputBorder(),
                helperText: 'Detailed product description',
              ),
            ),
            const SizedBox(height: 10),

            // Images section
            const Divider(),
            const Text(
              'Product Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Main Image URL Builder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Main Image URL Builder',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // Base URL display
                  Text(
                    'Base URL: $_baseUrl',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  
                  // Folder number selection
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFolderNumber,
                          decoration: const InputDecoration(
                            labelText: 'Folder Number',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(100, (index) {
                            String folderNum = (index + 1).toString().padLeft(3, '0');
                            return DropdownMenuItem(
                              value: folderNum,
                              child: Text(folderNum),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedFolderNumber = value!;
                              _updateMainImageUrl();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // Sub-image number selection
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImageNumber,
                          decoration: const InputDecoration(
                            labelText: 'Sub-Image',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(10, (index) {
                            String subNum = (index + 1).toString();
                            return DropdownMenuItem(
                              value: subNum,
                              child: Text('$_selectedFolderNumber-$subNum'),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImageNumber = value!;
                              _updateMainImageUrl();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // Extension selection
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedExtension,
                          decoration: const InputDecoration(
                            labelText: 'Extension',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'jpg', child: Text('jpg')),
                            DropdownMenuItem(value: 'png', child: Text('png')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedExtension = value!;
                              _updateMainImageUrl();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Generated URL display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generated URL: ${_buildImageUrl(_selectedFolderNumber, _selectedSubImageNumber, _selectedExtension)}',
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showImagePreview(_buildImageUrl(_selectedFolderNumber, _selectedSubImageNumber, _selectedExtension)),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Preview Image', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Sub-images section
            const Divider(),
            const Text(
              'Sub-Images with Colors (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Sub-image 1
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sub-Image 1', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // First Row: Folder, Sub, Extension
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage1FolderNumber,
                          decoration: const InputDecoration(
                            labelText: 'Folder',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: List.generate(100, (index) {
                            String folderNum = (index + 1).toString().padLeft(3, '0');
                            return DropdownMenuItem(value: folderNum, child: Text(folderNum, style: const TextStyle(fontSize: 12)));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage1FolderNumber = value!;
                              _updateSubImage1Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage1SubNumber,
                          decoration: const InputDecoration(
                            labelText: 'Sub',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: List.generate(10, (index) {
                            String subNum = (index + 1).toString();
                            return DropdownMenuItem(value: subNum, child: Text(subNum, style: const TextStyle(fontSize: 12)));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage1SubNumber = value!;
                              _updateSubImage1Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage1Extension,
                          decoration: const InputDecoration(
                            labelText: 'Ext',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'jpg', child: Text('jpg', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'png', child: Text('png', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage1Extension = value!;
                              _updateSubImage1Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Preview button
                      IconButton(
                        onPressed: _subImage1UrlController.text.isNotEmpty 
                            ? () => _showImagePreview(_subImage1UrlController.text)
                            : null,
                        icon: const Icon(Icons.preview, size: 18),
                        tooltip: 'Preview Image',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          minimumSize: const Size(32, 32),
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second Row: Color
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: _availableColors.map((color) {
                      return DropdownMenuItem(value: color, child: Text(color, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (value) {
                      _subImage1ColorController.text = value ?? 'Red';
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL: ${_buildImageUrl(_selectedSubImage1FolderNumber, _selectedSubImage1SubNumber, _selectedSubImage1Extension)}',
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Sub-image 2
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sub-Image 2', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // First Row: Folder, Sub, Extension
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage2FolderNumber,
                          decoration: const InputDecoration(
                            labelText: 'Folder',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: List.generate(100, (index) {
                            String folderNum = (index + 1).toString().padLeft(3, '0');
                            return DropdownMenuItem(value: folderNum, child: Text(folderNum, style: const TextStyle(fontSize: 12)));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage2FolderNumber = value!;
                              _updateSubImage2Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage2SubNumber,
                          decoration: const InputDecoration(
                            labelText: 'Sub',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: List.generate(10, (index) {
                            String subNum = (index + 1).toString();
                            return DropdownMenuItem(value: subNum, child: Text(subNum, style: const TextStyle(fontSize: 12)));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage2SubNumber = value!;
                              _updateSubImage2Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage2Extension,
                          decoration: const InputDecoration(
                            labelText: 'Ext',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'jpg', child: Text('jpg', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'png', child: Text('png', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage2Extension = value!;
                              _updateSubImage2Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _subImage2UrlController.text.isNotEmpty 
                            ? () => _showImagePreview(_subImage2UrlController.text)
                            : null,
                        icon: const Icon(Icons.preview, size: 18),
                        tooltip: 'Preview Image',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          minimumSize: const Size(32, 32),
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second Row: Color
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: _availableColors.map((color) {
                      return DropdownMenuItem(value: color, child: Text(color, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (value) {
                      _subImage2ColorController.text = value ?? 'Blue';
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL: ${_buildImageUrl(_selectedSubImage2FolderNumber, _selectedSubImage2SubNumber, _selectedSubImage2Extension)}',
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Sub-image 3
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sub-Image 3', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // First Row: Folder, Sub, Extension
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage3FolderNumber,
                          decoration: const InputDecoration(
                            labelText: 'Folder',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: List.generate(100, (index) {
                            String folderNum = (index + 1).toString().padLeft(3, '0');
                            return DropdownMenuItem(value: folderNum, child: Text(folderNum, style: const TextStyle(fontSize: 12)));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage3FolderNumber = value!;
                              _updateSubImage3Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage3SubNumber,
                          decoration: const InputDecoration(
                            labelText: 'Sub',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: List.generate(10, (index) {
                            String subNum = (index + 1).toString();
                            return DropdownMenuItem(value: subNum, child: Text(subNum, style: const TextStyle(fontSize: 12)));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage3SubNumber = value!;
                              _updateSubImage3Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubImage3Extension,
                          decoration: const InputDecoration(
                            labelText: 'Ext',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'jpg', child: Text('jpg', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'png', child: Text('png', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSubImage3Extension = value!;
                              _updateSubImage3Url();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Preview button
                      IconButton(
                        onPressed: _subImage3UrlController.text.isNotEmpty 
                            ? () => _showImagePreview(_subImage3UrlController.text)
                            : null,
                        icon: const Icon(Icons.preview, size: 18),
                        tooltip: 'Preview Image',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          minimumSize: const Size(32, 32),
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second Row: Color
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: _availableColors.map((color) {
                      return DropdownMenuItem(value: color, child: Text(color, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (value) {
                      _subImage3ColorController.text = value ?? 'Green';
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL: ${_buildImageUrl(_selectedSubImage3FolderNumber, _selectedSubImage3SubNumber, _selectedSubImage3Extension)}',
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Simple buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Product to Firestore'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isLoading ? null : _generateRandomProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Generate 2 Random Products'),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: _clearFields,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Clear Fields'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _countController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _midDescriptionController.dispose();
    _longDescriptionController.dispose();
    _subImage1UrlController.dispose();
    _subImage1ColorController.dispose();
    _subImage2UrlController.dispose();
    _subImage2ColorController.dispose();
    _subImage3UrlController.dispose();
    _subImage3ColorController.dispose();
    super.dispose();
  }
}
