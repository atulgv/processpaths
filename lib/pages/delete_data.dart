import 'package:flutter/material.dart';
import 'package:processpath/services/auth_service.dart';
import 'package:processpath/services/hive_service.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/routes.dart';
import '../services/sound_service.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _emailController = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitDeletionRequest() async {
    await SoundService.play('sounds/alert.wav');
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _reasonController.text.trim();
      final email = _emailController.text.trim();

      await FirestoreService.db.collection('deletion_requests').add({
        'reason': reason,
        'email': email,
        'confirmed': _confirmed,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint(
        'Delete Request:\nReason: $reason\nEmail: $email\nConfirmed: $_confirmed',
      );

      if (AuthService.instance.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your deletion request has been submitted. It will take 5 - 7 days for completion. Thanks for your patience.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'All your local data is deleted. You can make a new account.',
            ),
          ),
        );
      }

      _formKey.currentState?.reset();
      setState(() => _confirmed = false);
    }
    HiveService.clearAll();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account / Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'We’re sorry to see you go.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for deletion',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please provide a reason'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Your Email (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('I understand this action is irreversible'),
                value: _confirmed,
                onChanged: (value) =>
                    setState(() => _confirmed = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Submit Request'),
                onPressed: _confirmed ? _submitDeletionRequest : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
