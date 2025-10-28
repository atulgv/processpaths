import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalFeedbackPage extends StatefulWidget {
  const PersonalFeedbackPage({super.key});

  @override
  State<PersonalFeedbackPage> createState() => _PersonalFeedbackPageState();
}

class _PersonalFeedbackPageState extends State<PersonalFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _detailController = TextEditingController();
  final _emailController = TextEditingController();

  String? _appSatisfaction;
  String? _featureUsage;

  final List<String> satisfactionOptions = [
    'Very satisfied',
    'Satisfied',
    'Neutral',
    'Unsatisfied',
    'Very unsatisfied',
  ];

  final List<String> usageOptions = [
    'Daily',
    'Weekly',
    'Occasionally',
    'Rarely',
    'Never',
  ];

  @override
  void dispose() {
    _detailController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      final detail = _detailController.text.trim();
      final email = _emailController.text.trim();

      try {
        await FirestoreService.db.collection('user_feedback').add({
          'satisfaction': _appSatisfaction,
          'featureUsage': _featureUsage,
          'details': detail,
          'email': email,
          'timestamp': FieldValue.serverTimestamp(),
        });

        debugPrint(
          'Feedback Submitted:\nSatisfaction: $_appSatisfaction\nUsage: $_featureUsage\nDetails: $detail\nEmail: $email',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );

        _formKey.currentState?.reset();
        setState(() {
          _appSatisfaction = null;
          _featureUsage = null;
        });
      } catch (e) {
        debugPrint('Error submitting feedback: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Feedback')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We’d love to hear from you!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'How satisfied are you with the app?',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                ...satisfactionOptions.map(
                  (option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _appSatisfaction,
                    onChanged: (value) =>
                        setState(() => _appSatisfaction = value),
                  ),
                ),
                if (_appSatisfaction == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Please select an option',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 16),
                Text(
                  'How often do you use the app?',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                ...usageOptions.map(
                  (option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _featureUsage,
                    onChanged: (value) => setState(() => _featureUsage = value),
                  ),
                ),
                if (_featureUsage == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Please select an option',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Comments',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please share your thoughts'
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
                  icon: const Icon(Icons.feedback),
                  label: const Text('Submit Feedback'),
                  onPressed: (_appSatisfaction != null && _featureUsage != null)
                      ? _submitFeedback
                      : null,
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
