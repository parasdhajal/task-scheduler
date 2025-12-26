import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedPriority;
  final String? selectedStatus;
  final Function(String?) onCategoryChanged;
  final Function(String?) onPriorityChanged;
  final Function(String?) onStatusChanged;

  const FilterChipRow({
    super.key,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Categories',
            selected: selectedCategory == null,
            onSelected: (selected) => onCategoryChanged(null),
          ),
          _buildFilterChip(
            label: 'Scheduling',
            selected: selectedCategory == 'scheduling',
            onSelected: (selected) => onCategoryChanged('scheduling'),
          ),
          _buildFilterChip(
            label: 'Finance',
            selected: selectedCategory == 'finance',
            onSelected: (selected) => onCategoryChanged('finance'),
          ),
          _buildFilterChip(
            label: 'Technical',
            selected: selectedCategory == 'technical',
            onSelected: (selected) => onCategoryChanged('technical'),
          ),
          _buildFilterChip(
            label: 'Safety',
            selected: selectedCategory == 'safety',
            onSelected: (selected) => onCategoryChanged('safety'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'All Priorities',
            selected: selectedPriority == null,
            onSelected: (selected) => onPriorityChanged(null),
          ),
          _buildFilterChip(
            label: 'High',
            selected: selectedPriority == 'high',
            onSelected: (selected) => onPriorityChanged('high'),
          ),
          _buildFilterChip(
            label: 'Medium',
            selected: selectedPriority == 'medium',
            onSelected: (selected) => onPriorityChanged('medium'),
          ),
          _buildFilterChip(
            label: 'Low',
            selected: selectedPriority == 'low',
            onSelected: (selected) => onPriorityChanged('low'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'All Status',
            selected: selectedStatus == null,
            onSelected: (selected) => onStatusChanged(null),
          ),
          _buildFilterChip(
            label: 'Pending',
            selected: selectedStatus == 'pending',
            onSelected: (selected) => onStatusChanged('pending'),
          ),
          _buildFilterChip(
            label: 'In Progress',
            selected: selectedStatus == 'in_progress',
            onSelected: (selected) => onStatusChanged('in_progress'),
          ),
          _buildFilterChip(
            label: 'Completed',
            selected: selectedStatus == 'completed',
            onSelected: (selected) => onStatusChanged('completed'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}






