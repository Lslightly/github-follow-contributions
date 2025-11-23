import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'user_card_widget.dart';

class OptimizedListWidget extends StatelessWidget {
  final ScrollController scrollController;
  
  const OptimizedListWidget({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('加载失败'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => eventProvider.reloadEvents(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        if (eventProvider.displayedUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('加载中...'),
              ],
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final isNarrow = width < 600;
        final crossAxisCount = _getCrossAxisCount(context);
        final spacing = isNarrow ? 12.0 : 16.0;

        return MasonryGridView.count(
          controller: scrollController,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          itemCount: eventProvider.displayedUsers.length + 
            (eventProvider.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= eventProvider.displayedUsers.length) {
              // Loading indicator at the bottom
              return Container(
                padding: EdgeInsets.all(spacing),
                child: Center(
                  child: eventProvider.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
                ),
              );
            }
            
            final user = eventProvider.displayedUsers[index];
            return UserCardWidget(user: user);
          },
          padding: EdgeInsets.all(spacing),
        );
      },
    );
  }
  
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }
}