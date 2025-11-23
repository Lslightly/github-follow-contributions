import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../providers/event_provider.dart';

import '../widgets/legend_widget.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
         backgroundColor: const Color(0xFFF6F8FA),
         title: const Text('GitHub Follow Contributions'),
         bottom: PreferredSize(
           preferredSize: const Size.fromHeight(56),
           child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: Consumer<EventProvider>(
               builder: (context, provider, _) {
                 return TextField(
                   decoration: InputDecoration(
                     hintText: '筛选用户（按用户名）',
                     prefixIcon: const Icon(Icons.search, size: 20),
                     suffixIcon: provider.userQuery.isNotEmpty
                       ? IconButton(
                           icon: const Icon(Icons.clear, size: 20),
                           onPressed: () => provider.setUserQuery(''),
                         )
                       : null,
                     border: const OutlineInputBorder(),
                     isDense: true,
                     contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                   ),
                   onChanged: provider.setUserQuery,
                 );
               },
             ),
           ),
         ),
         actions: [
           IconButton(
             icon: Image.network(
               'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
               width: 24,
               height: 24,
             ),
             onPressed: () {
               final uri = Uri.parse('https://github.com/Lslightly/github-follow-contributions');
               unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
             },
           ),
         ],
       ),
      body: Column(
        children: [
          const LegendWidget(),
          Expanded(
            child: OptimizedListWidget(scrollController: _scrollController),
          ),
        ],
      ),
    );
  }
}