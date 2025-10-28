import 'package:flutter/material.dart';
import 'package:processpath/screens/sign_in_screen.dart';
import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/profile_avatar.dart';
import '../utils/dialog_utils.dart';
import '../routes/routes.dart';
import '../services/sound_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return const SignInScreen();
    }

    final isAnonymous = user.isAnonymous;
    final name = user.displayName ?? 'Guest User';
    final photoUrl = user.photoURL;

    return AppScaffold(
      title: 'Profile',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Account Info', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildProfileAvatar(photoUrl, radius: 100, textSize: 70),
                    SizedBox(height: 10),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Divider(height: 10),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Information',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      await SoundService.play('sounds/click.wav');
                      if (!context.mounted) return;

                      DialogUtils.showInfoDialog(
                        context,
                        'Name: ',
                        user.displayName ?? 'N/A',
                      );
                    },
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Name:'),
                      subtitle: Text(user.displayName ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      await SoundService.play('sounds/click.wav');
                      if (!context.mounted) return;

                      DialogUtils.showInfoDialog(
                        context,
                        'Email: ',
                        user.email ?? 'N/A',
                      );
                    },
                    child: ListTile(
                      leading: const Icon(Icons.mail),
                      title: const Text('Email:'),
                      subtitle: Text(user.email ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      await SoundService.play('sounds/click.wav');
                      if (!context.mounted) return;

                      DialogUtils.showInfoDialog(context, 'UID: ', user.uid);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('UID:'),
                      subtitle: Text(user.uid),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await SoundService.play('sounds/click.wav');
                      if (!isAnonymous) {
                        await AuthService.signOut();
                      }

                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    icon: Icon(!isAnonymous ? Icons.logout : Icons.login),
                    label: Text(!isAnonymous ? 'Sign Out' : 'Sign In'),
                  ),
                  const SizedBox(height: 30),
                  if (AuthService.instance.isLoggedIn)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await SoundService.play('sounds/click.wav');

                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      },
                      icon: const Icon(Icons.password),
                      label: const Text('Change Password'),
                    ),
                ],
              ),
              if (isAnonymous)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'You’re signed in as a guest. Create an account to save your data.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
