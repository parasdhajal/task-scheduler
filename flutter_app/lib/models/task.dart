class Task {
  final int id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? dueDate;
  final String? assignedTo;
  final Map<String, dynamic> extractedEntities;
  final List<String> suggestedActions;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.dueDate,
    this.assignedTo,
    required this.extractedEntities,
    required this.suggestedActions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      dueDate: json['due_date'] as String?,
      assignedTo: json['assigned_to'] as String?,
      extractedEntities: json['extracted_entities'] as Map<String, dynamic>? ?? {},
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'due_date': dueDate,
      'assigned_to': assignedTo,
      'extracted_entities': extractedEntities,
      'suggested_actions': suggestedActions,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TaskCreate {
  final String title;
  final String description;
  final String? dueDate;
  final String? assignedTo;

  TaskCreate({
    required this.title,
    required this.description,
    this.dueDate,
    this.assignedTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (assignedTo != null) 'assigned_to': assignedTo,
    };
  }
}
