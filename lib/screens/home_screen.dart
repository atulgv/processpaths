import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/process_tile.dart';
import '../routes/routes.dart';
import '../controllers/process_controller.dart';
import '../models/process.dart';
import '../services/auth_service.dart';
import '../services/sound_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Process> processes = [];
  String? userId = AuthService.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await ProcessController.loadProcesses();
    setState(() {
      processes = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Processes',
      body: ListView.builder(
        itemCount: processes.length,

        itemBuilder: (_, index) {
          final process = processes[index];
          return ProcessTile(
            key: ValueKey(process.id),
            process: process,
            onTap: () async {
              await SoundService.play('sounds/done.mp3');

              Navigator.pushNamed(
                context,
                AppRoutes.process,
                arguments: {'process': process, 'userId': userId ?? ''},
              );
            },
            onEdit: () async {
              final updated = await ProcessController.editProcess(
                context,
                index,
                processes,
              );
              if (updated != null) {
                setState(() {
                  processes[index] = updated;
                });
              }
            },
            onDelete: () async {
              final deleted = await ProcessController.deleteProcess(
                context,
                index,
                processes,
              );
              if (deleted != null) {
                setState(() {
                  processes.removeAt(index);
                });
              }
            },
          );
        },
      ),
      fab: FloatingActionButton(
        onPressed: () async {
          await SoundService.play('sounds/click.wav');

          final newProcess = await ProcessController.addProcess(context);
          if (newProcess != null) {
            setState(() {
              processes.add(newProcess);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
