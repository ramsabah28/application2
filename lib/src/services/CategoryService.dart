import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/CategoryModel.dart';

class CategoryService {
  static Future<List<CategoryModel>> loadCategories() async {
    try {
      final String response =
      await rootBundle.loadString('lib/src/data/category_Moc_.json');
      final List<dynamic> data = json.decode(response);

      return data.map<CategoryModel>((item) {
        return CategoryModel.fromJson(item);
      }).toList();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return [];
    }
  }
}

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kategorien"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: CategoryService.loadCategories(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Fehler: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Keine Kategorien gefunden"));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(category.name),
                subtitle: Text("ID: ${category.uuid}"),
              );
            },
          );
        },
      ),
    );
  }
}
