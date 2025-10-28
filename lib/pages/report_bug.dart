import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firestore_service.dart';

class ReportBugPage extends StatefulWidget {
  const ReportBugPage({super.key});

  @override
  State<ReportBugPage> createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _emailController = TextEditingController();
  final List<XFile> _screenshots = [];
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<List<String>> _uploadScreenshots(List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      final ref = FirebaseStorage.instance.ref(
        'bug_screenshots/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _selectScreenshot() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _screenshots.add(picked));
    }
  }

  Future<void> _submitBugReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);

      final title = _titleController.text.trim();
      final description = _descController.text.trim();
      final email = _emailController.text.trim();

      try {
        final screenshotUrls = await _uploadScreenshots(_screenshots);

        await FirestoreService.db.collection('bug_reports').add({
          'title': title,
          'description': description,
          'email': email,
          'screenshots': screenshotUrls,
          'timestamp': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bug report submitted. Thank you!')),
        );

        _formKey.currentState?.reset();
        setState(() {
          _screenshots.clear();
          _loading = false;
        });
      } catch (e) {
        debugPrint('Error uploading bug report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit bug report: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Bug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Found a bug? Let us know!',
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
                  labelText: 'Bug Title',
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
                  labelText: 'Bug Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please describe the bug'
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
                icon: const Icon(Icons.image),
                label: const Text('Attach Screenshot'),
                onPressed: _selectScreenshot,
              ),
              const SizedBox(height: 12),

              if (_screenshots.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _screenshots
                      .map(
                        (file) => Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(
                              File(file.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() => _screenshots.remove(file));
                              },
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bug_report),
                label: _loading
                    ? const Text('Submitting...')
                    : const Text('Submit Bug Report'),
                onPressed: _loading ? null : _submitBugReport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
