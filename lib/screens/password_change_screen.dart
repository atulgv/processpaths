import 'package:flutter/material.dart';
import 'package:processpath/screens/auth_gate.dart';
import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';
import '../routes/routes.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _changePassword() async {
    final user = AuthService.auth.currentUser;
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _showError('New passwords do not match.');
      return;
    }

    if (user?.email == null) {
      _showError('No authenticated user found.');
      return;
    }

    setState(() => _loading = true);

    try {
      // Re-authenticate the user
      final credential = AuthGate.emailCredential(
        email: user!.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword);
      _navigateToDashboard();
    } catch (e) {
      _showError('Password change failed: $e');
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Change Password',
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _oldPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Old Password',
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _changePassword,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
