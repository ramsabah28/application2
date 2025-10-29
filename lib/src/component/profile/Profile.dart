import 'package:application2/src/component/profile/Invoice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'Login.dart';
import 'Register.dart';
import 'Favorit.dart';
import 'Adress.dart';
import '../features/StandardButton.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileAuthSwitcher();
  }
}

class _ProfileAuthSwitcher extends StatefulWidget {
  @override
  State<_ProfileAuthSwitcher> createState() => _ProfileAuthSwitcherState();
}

class _ProfileAuthSwitcherState extends State<_ProfileAuthSwitcher> {
  bool showFavorit = false;
  bool showAdress = false;
  bool showInvoice = false;
  String? _avatarImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
  }

  Future<void> _loadAvatarImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarImagePath = prefs.getString('avatar_image_path');
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_image_path', image.path);
        setState(() {
          _avatarImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildAvatarImage() {
    if (_avatarImagePath != null && File(_avatarImagePath!).existsSync()) {
      return CircleAvatar(
        radius: 72,
        backgroundImage: FileImage(File(_avatarImagePath!)),
      );
    } else {
      return CircleAvatar(
        radius: 72,
        backgroundImage: AssetImage('lib/assets/avatar.jpg'),
      );
    }
  }

  void _showFavorit() {
    setState(() {
      showFavorit = true;
    });
  }

  void _showAdress() {
    setState(() {
      showAdress = true;
    });
  }

  bool showRegister = false;

  void _showRegister() {
    setState(() {
      showRegister = true;
    });
  }

  void _showLogin() {
    setState(() {
      showRegister = false;
    });
  }

  void _showInvoice() {
    setState(() {
      showInvoice = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          if (showRegister) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RegisterScreen(key: ValueKey('register')),
                TextButton(
                  onPressed: _showLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorDark,
                  ),
                  child: Text('Back to Login'),
                ),
              ],
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoginScreen(),
              TextButton(
                onPressed: _showRegister,
                child: Text('create new account'),
              ),
            ],
          );
        }
        // User is logged in
        if (showFavorit) {
          return Favorit();
        }
        if (showAdress) {
          return AdressScreen();
        }

        if (showInvoice) {
          return Invoice();
        }

        final Color bgColor = const Color(0xFFF5F6FA);
        return Container(
          color: bgColor,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with tap to change functionality
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        _buildAvatarImage(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Name
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email
                  Text(
                    'johndoe@email.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(thickness: 1.2, color: Colors.grey[300]),
                  const SizedBox(height: 24),
                  const SizedBox(height: 8),
                  _ProfileActionButton(
                    icon: Icons.home_outlined,
                    label: 'Adresse',
                    accent: Theme.of(context).primaryColor,
                    onTap: _showAdress,
                  ),
                  const SizedBox(height: 24),
                  // Modern Buttons
                  _ProfileActionButton(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Bestellungen',
                    accent: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _ProfileActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Rechnungen',
                    accent: Theme.of(context).primaryColor,
                    onTap: _showInvoice,
                  ),
                  const SizedBox(height: 16),
                  _ProfileActionButton(
                    icon: Icons.favorite_border,
                    label: 'Mein Favorit list',
                    accent: Theme.of(context).primaryColor,
                    onTap: _showFavorit,
                  ),
                  const SizedBox(height: 32),
                  StandardButton(
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).primaryColor,
                    ),
                    backgroundColor: Theme.of(context).primaryColorDark,
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onTap;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColorLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
