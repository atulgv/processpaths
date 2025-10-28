import 'package:flutter/material.dart';
import 'app_drawer.dart';

/// Reusable scaffold with drawer and dynamic title
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? fab;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: fab,
    );
  }
}
