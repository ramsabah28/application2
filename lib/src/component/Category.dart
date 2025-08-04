import 'package:flutter/material.dart';
import '../data/CustomColors.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _Category();
}

class _Category extends State<Category> {
  final List<Map<String, String>> categories = [
    {
      'name': 'Electronics',
      'description': 'Gadgets, phones, and more',
      'imageUrl':
          'https://i.otto.de/i/otto/bd194e95-57f5-5180-8844-8c7730789eb1?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto',
    },
    {
      'name': 'Clothing',
      'description': 'Men\'s and women\'s fashion',
      'imageUrl':
          'https://i.otto.de/i/otto/bd194e95-57f5-5180-8844-8c7730789eb1?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto',
    },
    {
      'name': 'Books',
      'description': 'Fiction, non-fiction, and more',
      'imageUrl':
          'https://i.otto.de/i/otto/bd194e95-57f5-5180-8844-8c7730789eb1?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto',
    },
    {
      'name': 'Home & Kitchen',
      'description': 'Essentials for daily living',
      'imageUrl':
          'https://i.otto.de/i/otto/bd194e95-57f5-5180-8844-8c7730789eb1?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: CustomColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.network(
                  category['imageUrl']!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primery,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: CustomColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
