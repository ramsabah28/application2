import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/StandardButton.dart';

class Konto extends StatefulWidget {
  const Konto({super.key});

  @override
  State<Konto> createState() => _KontoState();
}

class _KontoState extends State<Konto> {
  final _currentEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoadingEmail = false;
  bool _isLoadingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentEmail();
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadCurrentEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _currentEmailController.text = user.email!;
    }
  }

  Future<void> _changeEmail() async {
    if (_newEmailController.text.trim().isEmpty) {
      _showMessage('Please enter a new email address');
      return;
    }

    if (_currentPasswordController.text.isEmpty) {
      _showMessage('Please enter your current password to verify identity');
      return;
    }

    setState(() {
      _isLoadingEmail = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user before changing email
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.verifyBeforeUpdateEmail(_newEmailController.text.trim());
      await user.sendEmailVerification();

      _showMessage('Email updated successfully! Please check your new email for verification.');
      _loadCurrentEmail();
      _newEmailController.clear();
      _currentPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      String message = 'Failed to update email';
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'email-already-in-use':
          message = 'This email is already in use by another account';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        default:
          message = e.message ?? 'Failed to update email';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEmail = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      _showMessage('Please enter your current password');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showMessage('Please enter a new password');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showMessage('New password must be at least 6 characters long');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showMessage('New passwords do not match');
      return;
    }

    setState(() {
      _isLoadingPassword = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text);

      _showMessage('Password updated successfully!');
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      String message = 'Failed to update password';
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'Password is too weak. Please choose a stronger password';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        default:
          message = e.message ?? 'Failed to update password';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPassword = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Konto verwalten',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'E-Mail-Adresse und Passwort ändern',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Email Change Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-Mail-Adresse ändern',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Email (Read-only)
                  TextField(
                    controller: _currentEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Aktuelle E-Mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  
                  // New Email
                  TextField(
                    controller: _newEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Neue E-Mail-Adresse',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoadingEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Password for Email Change
                  TextField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Aktuelles Passwort zur Bestätigung',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureCurrentPassword,
                    enabled: !_isLoadingEmail,
                  ),
                  const SizedBox(height: 20),
                  
                  // Change Email Button
                  SizedBox(
                    width: double.infinity,
                    child: StandardButton(
                      icon: Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: _isLoadingEmail ? null : _changeEmail,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Password Change Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passwort ändern',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Password
                  TextField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Aktuelles Passwort',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureCurrentPassword,
                    enabled: !_isLoadingPassword,
                  ),
                  const SizedBox(height: 16),
                  
                  // New Password
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Neues Passwort',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      helperText: 'Mindestens 6 Zeichen',
                    ),
                    obscureText: _obscureNewPassword,
                    enabled: !_isLoadingPassword,
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm New Password
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Neues Passwort bestätigen',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isLoadingPassword,
                  ),
                  const SizedBox(height: 20),
                  
                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: StandardButton(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: _isLoadingPassword ? null : _changePassword,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Security Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aus Sicherheitsgründen müssen Sie Ihr aktuelles Passwort eingeben, um Änderungen vorzunehmen.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
