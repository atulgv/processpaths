import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/process_service.dart';
import '../services/entry_service.dart';
import '../services/point_service.dart';
import '../services/hive_service.dart';
import '../services/auth_service.dart';
import '../routes/routes.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId:
            '117423785625-36r84lq1lf5mve34fi94d4lefkvrab88.apps.googleusercontent.com',
      );
      await googleSignIn.signOut(); // Ensure fresh login

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('🟡 Google sign-in cancelled by user');
        return;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint(
          '🔴 Missing tokens: accessToken=${googleAuth.accessToken}, idToken=${googleAuth.idToken}',
        );
        throw Exception('Missing Google auth tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      final userCredential = await AuthService.auth.signInWithCredential(
        credential,
      );
      final userId = userCredential.user?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Missing user ID after Google sign-in');
      }

      // Load guest Hive data
      final processes = await ProcessService.loadProcessesFromHive();
      if (processes.isEmpty) {
        debugPrint('🟡 No guest processes found in Hive');
      } else {
        // Sync guest data to Firestore
        await ProcessService.syncProcessesHiveToFirestore();

        for (final process in processes) {
          await HiveService.preloadEntryBoxes(processes);
          await EntryService.syncEntriesHiveToFirestore(process);

          final entries = HiveService.entryBoxFor(process).values.toList();
          await HiveService.preloadPointBoxes(entries);

          for (final entry in entries) {
            await PointService.syncPointsHiveToFirestore(process.id, entry);
          }
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guest Data uploaded to Google')),
        );
      }

      // Clear guest Hive data and reinitialize for signed-in user
      await HiveService.clearAll();
      await HiveService.initialize();
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e, stack) {
      debugPrint('❌ Google sign-in error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );
    }
  }

  static Future<void> signInWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await AuthService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final userId = userCredential.user?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Missing user ID after email sign-in');
      }

      // Load guest Hive data
      final processes = await ProcessService.loadProcessesFromHive();
      if (processes.isEmpty) {
        debugPrint('🟡 No guest processes found in Hive');
      } else {
        for (final process in processes) {
          await HiveService.preloadEntryBoxes(processes);
          await EntryService.syncEntriesHiveToFirestore(process);

          final entries = HiveService.entryBoxFor(process).values.toList();
          await HiveService.preloadPointBoxes(entries);

          for (final entry in entries) {
            await PointService.syncPointsHiveToFirestore(process.id, entry);
          }
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Guest Data uploaded to Email')));
      }

      // Clear guest Hive data and reinitialize for signed-in user
      await HiveService.clearAll();
      await HiveService.initialize();
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e, stack) {
      debugPrint('❌ Email sign-in error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sign-in failed: ${e.toString()}')),
      );
    }
  }

  static AuthCredential emailCredential({
    required String email,
    required String password,
  }) {
    return EmailAuthProvider.credential(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        Future.microtask(() {
          Navigator.pushReplacementNamed(
            context,
            user == null ? AppRoutes.login : AppRoutes.home,
          );
        });

        return const SizedBox.shrink();
      },
    );
  }
}
