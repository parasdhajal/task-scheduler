import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/filter_chip_row.dart';

class TaskDashboard extends ConsumerStatefulWidget {
  const TaskDashboard({super.key});

  @override
  ConsumerState<TaskDashboard> createState() => _TaskDashboardState();
}

class _TaskDashboardState extends ConsumerState<TaskDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(taskListProvider.notifier).setFilters(
          category: _selectedCategory,
          priority: _selectedPriority,
          status: _selectedStatus,
          search: _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);
    final taskNotifier = ref.read(taskListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dashboard'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected to server')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => taskNotifier.refresh(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  _applyFilters();
                },
              ),
            ),

            FilterChipRow(
              selectedCategory: _selectedCategory,
              selectedPriority: _selectedPriority,
              selectedStatus: _selectedStatus,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                _applyFilters();
              },
              onPriorityChanged: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
                _applyFilters();
              },
              onStatusChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
                _applyFilters();
              },
            ),

            // Task list or loading/error states
            Expanded(
              child: _buildTaskList(taskState, taskNotifier),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskForm(context, taskNotifier),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildTaskList(TaskListState state, TaskListNotifier notifier) {
    if (state.isLoading && state.tasks.isEmpty) {
      return const TaskSkeleton();
    }

    if (state.error != null && state.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create a new task',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.tasks.length + (state.page < state.totalPages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.tasks.length) {
          notifier.loadMore();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final task = state.tasks[index];
        return TaskItem(
          task: task,
          onTap: () => _showTaskDetails(context, task, notifier),
          onDelete: () => _confirmDelete(context, task, notifier),
        );
      },
    );
  }

  void _showTaskForm(BuildContext context, TaskListNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormSheet(
        onSave: (task) async {
          final success = await notifier.createTask(task);
          if (context.mounted) {
            Navigator.pop(context);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task created successfully!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${notifier.state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showTaskDetails(
      BuildContext context, Task task, TaskListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${task.description}'),
              const SizedBox(height: 8),
              Text('Category: ${task.category}'),
              Text('Priority: ${task.priority}'),
              Text('Status: ${task.status}'),
              if (task.dueDate != null) Text('Due: ${task.dueDate}'),
              if (task.assignedTo != null) Text('Assigned to: ${task.assignedTo}'),
              if (task.suggestedActions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Suggested Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...task.suggestedActions.map((action) => Text('• $action')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task, TaskListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.deleteTask(task.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${notifier.state.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}






