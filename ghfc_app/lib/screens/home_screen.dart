import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/combined_filter_widget.dart';
import '../widgets/optimized_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
    
    // Add scroll listener for lazy loading
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      if (!eventProvider.isLoadingMore && eventProvider.hasMoreData) {
        eventProvider.loadMoreUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: const CustomAppBar(),
        body: Column(
          children: [
            CombinedFilterWidget(scrollController: _scrollController),
            Expanded(
              child: OptimizedListWidget(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}