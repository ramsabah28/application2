import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.deepPurpleAccent;
    final Color bgColor = const Color(0xFFF5F6FA);

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bigger circular profile image
              CircleAvatar(
                radius: 72, // Increased from 48 to 72
                backgroundImage: AssetImage('lib/assets/avatar.jpg'),
              ),
              const SizedBox(height: 32), // Slightly more space below the bigger avatar
              // Name
              Text(
                'John Doe',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accent),
              ),
              const SizedBox(height: 8),
              // Email
              Text(
                'johndoe@email.com',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              Divider(thickness: 1.2, color: Colors.grey[300]),
              const SizedBox(height: 24),
              // Address
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '123 Placeholder St, City, Country',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 32),
              // Modern Buttons
              _ProfileActionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'Bestellungen',
                accent: accent,
              ),
              const SizedBox(height: 16),
              _ProfileActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'Rechnungen',
                accent: accent,
              ),
              const SizedBox(height: 16),
              _ProfileActionButton(
                icon: Icons.favorite_border,
                label: 'Mein Favorit list',
                accent: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(width: 18),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
