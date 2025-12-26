import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class TaskSkeleton extends StatelessWidget {
  const TaskSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: TaskSkeletonItem(),
        );
      },
    );
  }
}

class TaskSkeletonItem extends StatelessWidget {
  const TaskSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonContainer(width: 150, height: 20),
                SkeletonContainer(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonContainer(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const SkeletonContainer(width: 200, height: 14),
            const SizedBox(height: 16),
            const Row(
              children: [
                SkeletonContainer(width: 80, height: 24),
                SizedBox(width: 8),
                SkeletonContainer(width: 80, height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
