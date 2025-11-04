import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../models/UserModel.dart';
import 'Login.dart';
import 'Register.dart';
import '../features/StandardButton.dart';
import '../../services/UserService.dart';

class Profile extends StatelessWidget {
  final VoidCallback? onShowAddress;
  final VoidCallback? onShowOrders;
  final VoidCallback? onShowInvoices;
  final VoidCallback? onShowFavorites;
  final VoidCallback? onShowUserReview;

  const Profile({
    super.key,
    this.onShowAddress,
    this.onShowOrders,
    this.onShowInvoices,
    this.onShowFavorites,
    this.onShowUserReview,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileAuthSwitcher(
      onShowAddress: onShowAddress,
      onShowOrders: onShowOrders,
      onShowInvoices: onShowInvoices,
      onShowFavorites: onShowFavorites,
      onShowUserReview: onShowUserReview,
    );
  }
}

class _ProfileAuthSwitcher extends StatefulWidget {
  final VoidCallback? onShowAddress;
  final VoidCallback? onShowOrders;
  final VoidCallback? onShowInvoices;
  final VoidCallback? onShowFavorites;
  final VoidCallback? onShowUserReview;

  const _ProfileAuthSwitcher({
    this.onShowAddress,
    this.onShowOrders,
    this.onShowInvoices,
    this.onShowFavorites,
    this.onShowUserReview,
  });

  @override
  State<_ProfileAuthSwitcher> createState() => _ProfileAuthSwitcherState();
}

class _ProfileAuthSwitcherState extends State<_ProfileAuthSwitcher> {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
    widget.onShowFavorites?.call();
  }

  void _showUserReview() {
    widget.onShowUserReview?.call();
  }

  void _showAdress() {
    widget.onShowAddress?.call();
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
    widget.onShowInvoices?.call();
  }

  void _showOrder() {
    widget.onShowOrders?.call();
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
        // User is logged in - Always show profile interface
        final Color bgColor = const Color(0xFFF5F6FA);
        return Container(
          color: bgColor,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: StreamBuilder<UserData?>(
                stream: UserService.getCurrentUserDataStream(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final userData = userSnapshot.data;
                  final displayName = userData != null && UserService.getFullName(userData).isNotEmpty
                      ? UserService.getFullName(userData)
                      : 'User';
                  final displayEmail = userData != null && UserService.getDisplayEmail(userData).isNotEmpty
                      ? UserService.getDisplayEmail(userData)
                      : snapshot.data?.email ?? 'No email';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

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

                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        displayEmail,
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
                        onTap: _showOrder,
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
                        label: 'Favorit',
                        accent: Theme.of(context).primaryColor,
                        onTap: _showFavorit,
                      ),
                      const SizedBox(height: 16),
                      _ProfileActionButton(
                        icon: Icons.rate_review_outlined,
                        label: 'Meine Bewertungen',
                        accent: Theme.of(context).primaryColor,
                        onTap: _showUserReview,
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
                      // Admin button - only show for admin users
                      FutureBuilder<bool>(
                        future: snapshot.data?.uid != null
                            ? UserService.isUserAdmin(snapshot.data!.uid)
                            : Future.value(false),
                        builder: (context, adminSnapshot) {
                          if (adminSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }

                          final isAdmin = adminSnapshot.data ?? false;
                          if (!isAdmin) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: StandardButton(
                              icon: Icon(
                                Icons.admin_panel_settings,
                                color: Theme.of(context).primaryColor,
                              ),
                              backgroundColor: Theme.of(context).primaryColorDark,
                              onPressed: () async {
                                // TODO: Add admin panel functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Admin Panel - Coming Soon')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
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
