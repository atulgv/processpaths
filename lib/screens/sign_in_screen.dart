import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'auth_gate.dart';
import '../services/sound_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;

  Future<void> _signInAsGuest() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInAnonymously();
      _navigateToDashboard();
    } catch (e) {
      _showError('Guest sign-in failed: $e');
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
    const Color backgroundColor = Color(0xFFE6F0F8);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 48.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: screenHeight * 0.15,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        AppConstants.welcomeMessage,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      InkWell(
                        onTap: () async {
                          await SoundService.play('sounds/click.wav');

                          AuthGate.signInWithGoogle(context);
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      InkWell(
                        onTap: () async {
                          await SoundService.play('sounds/click.wav');

                          Navigator.pushNamed(context, AppRoutes.emailSignIn);
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.mail, color: Colors.redAccent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Sign in with Email',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      InkWell(
                        onTap: () async {
                          await SoundService.play('sounds/click.wav');

                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.app_registration_outlined,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      InkWell(
                        onTap: () async {
                          await SoundService.play('sounds/click.wav');
                          _signInAsGuest();
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_4, color: Colors.redAccent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Continue as Guest',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
