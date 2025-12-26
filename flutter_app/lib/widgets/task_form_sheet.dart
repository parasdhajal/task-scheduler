import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskFormSheet extends StatefulWidget {
  final Function(TaskCreate) onSave;

  const TaskFormSheet({
    super.key,
    required this.onSave,
  });

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  DateTime? _selectedDate;
  String? _autoCategory;
  String? _autoPriority;
  List<String> _autoSuggestedActions = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  void _analyzeText() {
    final title = _titleController.text.toLowerCase();
    final description = _descriptionController.text.toLowerCase();
    final combined = '$title $description';

    if (combined.contains('meeting') || combined.contains('schedule')) {
      _autoCategory = 'scheduling';
      _autoPriority = 'medium';
      _autoSuggestedActions = [
        'Check calendar availability',
        'Send meeting invites',
      ];
    } else if (combined.contains('payment') || combined.contains('invoice')) {
      _autoCategory = 'finance';
      _autoPriority = 'high';
      _autoSuggestedActions = [
        'Review budget allocation',
        'Process payment',
      ];
    } else if (combined.contains('bug') || combined.contains('code')) {
      _autoCategory = 'technical';
      _autoPriority = 'high';
      _autoSuggestedActions = [
        'Review code changes',
        'Run tests',
      ];
    } else {
      _autoCategory = 'general';
      _autoPriority = 'medium';
      _autoSuggestedActions = ['Review task details'];
    }

    setState(() {});
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final task = TaskCreate(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
        assignedTo: _assignedToController.text.trim().isEmpty
            ? null
            : _assignedToController.text.trim(),
      );

      widget.onSave(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Task',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  onChanged: (_) => _analyzeText(),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Enter task description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  onChanged: (_) => _analyzeText(),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _assignedToController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned To',
                    hintText: 'Person name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                if (_autoCategory != null && _titleController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto-classification Preview:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'Category: ${_autoCategory!.toUpperCase()}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.blue.shade100,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                'Priority: ${_autoPriority!.toUpperCase()}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.orange.shade100,
                            ),
                          ],
                        ),
                        if (_autoSuggestedActions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Suggested Actions:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          ..._autoSuggestedActions.map(
                            (action) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text(
                                '• $action',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'You can override these after saving',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create Task',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






