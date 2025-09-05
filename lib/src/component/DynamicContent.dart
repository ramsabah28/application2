import 'package:flutter/material.dart';
import 'features/AddInCartButton.dart';
import 'features/FavButton.dart';

class DynamicContent extends StatelessWidget {
  final String uuid;

  const DynamicContent({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    final product = {
      'name': 'E-Bike Mountainbike MONTIS',
      'brand': 'FISCHER FAHRRAD',
      'imageUrl':
          'https://i.otto.de/i/otto/780c2bee-3edd-5458-ad7d-68e45a82cd42?h=1040&w=1102&qlt=40&unsharp=0,1,0.6,7&sm=clamp&upscale=true&fmt=auto',
      'description':
          'Der vollgefederte E-MTB Klassiker mit kräftigem Mittelmotor bringt Dich mühelos auf den Berg und zeigt abwärts, was es auch in ruppigen Passagen leisten kann. Kraftvoll zupackenden hydraulischen Scheibenbremsen, bieten die notwendige Sicherheit, wenn’s darauf ankommt. Das Pedelec bietet über das Display die Konnektivität via Bluetooth zur FISCHER E-Connect-App.',
      'price': '1.300,00€',
      'delivery': 'GRATIS Lieferung 16-18. Mai',
      'why':
          'Erlebe das ultimative Abenteuer mit unseren E-Mountainbikes MONTIS! Der leistungsstarke Motor unterstützt dich auf jedem Trail und die hochwertige Federung sowie robusten Bremsen sorgen für präzise Kontrolle bei jeder Ab- und Auffahrt.',
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['brand']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              product['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 16),
            // Product Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                  child: Image.network(
                    product['imageUrl']!,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Description
            Text(product['description']!, style: const TextStyle(fontSize: 15)),
            SizedBox(height: 16),
            // Price
            Text(
              product['price']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            SizedBox(height: 4),
            // Delivery
            Text(
              product['delivery']!,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: AddInCartButton()),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    child: FavButton(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 8),
            // Why section
            Text(
              'Warum das MONTIS Rad zu dir passt?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(product['why']!, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
