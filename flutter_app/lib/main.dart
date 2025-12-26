import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/task_dashboard.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TaskSchedulerApp(),
    ),
  );
}

class TaskSchedulerApp extends StatelessWidget {
  const TaskSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Scheduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TaskDashboard(),
    );
  }
}
