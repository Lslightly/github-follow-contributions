import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_filter_dropdown.dart';
import '../widgets/legend_widget.dart';
import '../widgets/user_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        title: const Text('GitHub Follow Contributions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Open GitHub repository
              // This will be implemented with url_launcher
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter dropdown
                EventFilterDropdown(),
                const SizedBox(height: 20),
                
                // Legend
                const LegendWidget(),
                const SizedBox(height: 20),
                
                // User cards
                ...eventProvider.filteredUsers.map((user) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: UserCardWidget(user: user),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}