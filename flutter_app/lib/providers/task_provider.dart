import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: 'http://10.15.55.226:8000');
});

final taskListProvider = StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier(ref.read(apiServiceProvider));
});

class TaskListState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
    this.totalPages = 0,
  });

  TaskListState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    int? pageSize,
    int? totalPages,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class TaskListNotifier extends StateNotifier<TaskListState> {
  final ApiService _apiService;
  String? _categoryFilter;
  String? _priorityFilter;
  String? _statusFilter;
  String? _searchQuery;

  TaskListNotifier(this._apiService) : super(TaskListState()) {
    loadTasks();
  }

  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(page: 1);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getTasks(
        page: state.page,
        pageSize: state.pageSize,
        category: _categoryFilter,
        priority: _priorityFilter,
        status: _statusFilter,
        search: _searchQuery,
      );

      final tasks = (response['tasks'] as List)
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        tasks: refresh ? tasks : [...state.tasks, ...tasks],
        isLoading: false,
        total: response['total'] as int,
        totalPages: response['total_pages'] as int,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadTasks(refresh: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.page >= state.totalPages) return;

    state = state.copyWith(page: state.page + 1);
    await loadTasks();
  }

  void setFilters({
    String? category,
    String? priority,
    String? status,
    String? search,
  }) {
    _categoryFilter = category;
    _priorityFilter = priority;
    _statusFilter = status;
    _searchQuery = search;
    refresh();
  }

  Future<bool> createTask(TaskCreate task) async {
    try {
      await _apiService.createTask(task);
      refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> updateTask(int id, Map<String, dynamic> updates) async {
    try {
      await _apiService.updateTask(id, updates);
      
      final updatedTasks = state.tasks.map((task) {
        if (task.id == id) {
          final json = task.toJson();
          updates.forEach((key, value) {
            json[key] = value;
          });
          return Task.fromJson(json);
        }
        return task;
      }).toList();
      
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      
      final updatedTasks = state.tasks.where((task) => task.id != id).toList();
      state = state.copyWith(tasks: updatedTasks, total: state.total - 1);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
