import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  Color _getCategoryColor() {
    switch (task.category) {
      case 'scheduling':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'technical':
        return Colors.purple;
      case 'safety':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    task.category.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getCategoryColor().withOpacity(0.2),
                  labelStyle: TextStyle(color: _getCategoryColor()),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                Chip(
                  label: Text(
                    task.priority.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getPriorityColor().withOpacity(0.2),
                  labelStyle: TextStyle(color: _getPriorityColor()),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                Chip(
                  avatar: Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: _getStatusColor(),
                  ),
                  label: Text(
                    task.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor().withOpacity(0.2),
                  labelStyle: TextStyle(color: _getStatusColor()),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            if (task.dueDate != null || task.assignedTo != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (task.dueDate != null) ...[
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  if (task.dueDate != null && task.assignedTo != null)
                    const SizedBox(width: 16),
                  if (task.assignedTo != null) ...[
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedTo!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}






