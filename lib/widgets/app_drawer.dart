import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../routes/routes.dart';
import 'profile_avatar.dart';
import '../services/sound_service.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;
    final photoUrl = user?.photoURL;
    final displayName = isAnonymous
        ? 'Guest'
        : (user?.displayName?.isNotEmpty == true ? user!.displayName! : 'User');

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/icons/log.png', height: 50, width: 50),
                SizedBox(height: 10),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            Divider(),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16), // inner padding
              decoration: BoxDecoration(
                color: Colors.white, // slab background
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Welcome $displayName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await SoundService.play('sounds/click.wav');
                      final isLoggedIn = user != null;
                      final route = isLoggedIn
                          ? AppRoutes.profile
                          : AppRoutes.login;

                      Navigator.pushNamed(context, route);
                    },
                    child: buildProfileAvatar(photoUrl, radius: 20),
                  ),
                ],
              ),
            ),
            // Navigation links
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () async {
                await SoundService.play('sounds/click.wav');

                Navigator.pushNamed(context, AppRoutes.home);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () async {
                await SoundService.play('sounds/click.wav');

                Navigator.pushNamed(context, AppRoutes.setting);
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help and Support'),
              onTap: () async {
                await SoundService.play('sounds/click.wav');

                Navigator.pushNamed(context, AppRoutes.help);
              },
            ),

            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () async {
                await SoundService.play('sounds/click.wav');

                Navigator.pushNamed(context, AppRoutes.feedback);
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Info'),
              onTap: () async {
                await SoundService.play('sounds/click.wav');

                Navigator.pushNamed(context, AppRoutes.about);
              },
            ),

            // Exit app (optional)
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Exit'),
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
