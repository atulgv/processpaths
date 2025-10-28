import 'package:flutter/material.dart';
import 'package:processpath/pages/legal_contracts.dart';
import 'package:processpath/pages/report_bug.dart';
import '../screens/auth_gate.dart';
import '../screens/email_signin_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/process_screen.dart';
import '../screens/register_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/entry_screen.dart';
import '../screens/about_screen.dart';
import '../screens/help_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/password_change_screen.dart';

import '../pages/copyright.dart';
import '../pages/delete_data.dart';
import '../pages/feature_request.dart';
import '../pages/help_page.dart';
import '../pages/personal_feedback.dart';
import '../pages/privacy.dart';
import '../pages/terms.dart';

/// Centralized route definitions
class AppRoutes {
  // core
  static const String splash = '/';
  static const String authGate = '/auth_gate';

  // sign in and sign up
  static const String login = '/sign_in';
  static const String register = '/register';
  static const String emailSignIn = '/email_sign_in';
  static const String changePassword = '/change_password';

  // settings
  static const String setting = '/setting';
  static const String profile = '/profile';

  // screens
  static const String home = '/home';
  static const String process = '/process';
  static const String entry = '/entry';

  // other
  static const String about = '/about';
  static const String help = '/help';
  static const String feedback = '/feedback';

  //pages
  static const String deleteData = '/delete_data';
  static const String reportBug = '/bug_report';
  static const String featureRequest = '/feature_request';
  static const String helpPage = '/help_page';
  static const String personalFeedback = '/personal_feedback';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String copyright = '/copyright';
  static const String legalContracts = '/legal_contracts';

  /// Handles dynamic route generation
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // core
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());

      // sign in and sign up
      case login:
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case emailSignIn:
        return MaterialPageRoute(builder: (_) => const EmailSignInScreen());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const PasswordChangeScreen());

      // settings
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // screens
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case process:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              ProcessScreen(process: args['process'], userId: args['userId']),
        );

      case entry:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EntryScreen(
            userId: args['userId'],
            processId: args['processId'],
            entry: args['entry'],
            entryId: args['entryId'],
          ),
        );

      // other sections
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());

      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());

      // pages
      case deleteData:
        return MaterialPageRoute(builder: (_) => const DeleteAccountPage());

      case reportBug:
        return MaterialPageRoute(builder: (_) => const ReportBugPage());

      case featureRequest:
        return MaterialPageRoute(builder: (_) => const RequestFeaturePage());

      case helpPage:
        return MaterialPageRoute(builder: (_) => const HelpPage());

      case personalFeedback:
        return MaterialPageRoute(builder: (_) => const PersonalFeedbackPage());

      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());

      case terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case copyright:
        return MaterialPageRoute(builder: (_) => const CopyrightScreen());

      case legalContracts:
        return MaterialPageRoute(builder: (_) => const LegalContractsScreen());

      // default fallback
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
