import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../utils/constants.dart';
import '../routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    debugPrint('⏳ Waiting 5 seconds before navigation...');
    await Future.delayed(const Duration(seconds: 5));

    final user = AuthService.instance.currentUser;
    debugPrint('✅ Delay complete. Current user: $user');

    debugPrint('➡️ Navigating to ${user == null ? 'AuthGate' : 'Home'}');
    Navigator.pushReplacementNamed(
      context,
      user == null ? AppRoutes.authGate : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.5,
            ),

            const SizedBox(height: 32),

            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Visualize your goals and track your progress',
                    textStyle: const TextStyle(
                      fontSize: 22,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
