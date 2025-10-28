import 'package:flutter/material.dart';
import '../screens/auth_gate.dart';
import '../widgets/app_scaffold.dart';
import '../services/auth_service.dart';
import '../services/sound_service.dart';

class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _signInWithEmail() async {
    setState(() => _loading = true);
    try {
      await AuthGate.signInWithEmail(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      _showError('Email sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sign In',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Email Field ---
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Email address',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Password Field ---
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- Forgot Password Link ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await SoundService.play('sounds/click.wav');
                  final email = _emailController.text.trim();

                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email address'),
                      ),
                    );
                    return;
                  }

                  try {
                    await AuthService.auth.sendPasswordResetEmail(email: email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send reset email: $e')),
                    );
                  }
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Primary Sign In Button ---
            ElevatedButton(
              onPressed: _loading ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        'Sign In Securely',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
