import 'package:flutter/material.dart';
import 'package:processpath/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestFeaturePage extends StatefulWidget {
  const RequestFeaturePage({super.key});

  @override
  State<RequestFeaturePage> createState() => _RequestFeaturePageState();
}

class _RequestFeaturePageState extends State<RequestFeaturePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descController.text.trim();
      final email = _emailController.text.trim();

      try {
        await FirestoreService.db.collection('feature_requests').add({
          'title': title,
          'description': description,
          'email': email,
          'timestamp': FieldValue.serverTimestamp(),
        });

        debugPrint(
          'Feature Requested:\nTitle: $title\nDescription: $description\nEmail: $email',
        );
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature request submitted. Thank you!'),
          ),
        );

        _formKey.currentState?.reset();
      } catch (e) {
        if (!mounted) return;

        debugPrint('Error submitting feature request: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request a Feature')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Tell us what you’d love to see!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Feature Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Feature Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please describe the feature'
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
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit Request'),
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
