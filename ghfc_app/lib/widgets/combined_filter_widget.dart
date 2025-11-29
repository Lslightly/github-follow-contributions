import 'package:flutter/material.dart';
import 'package:ghfc_app/utils/color.dart';
import 'package:ghfc_app/widgets/category_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../providers/event_provider.dart';
import '../utils/localizations.dart';

class CombinedFilterWidget extends StatefulWidget {
  final ScrollController scrollController;
  
  const CombinedFilterWidget({
    super.key,
    required this.scrollController,
  });
  
  @override
  State<CombinedFilterWidget> createState() => _CombinedFilterWidgetState();
}

class _CombinedFilterWidgetState extends State<CombinedFilterWidget> {
  bool _isExpanded = true;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;
  
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    // 监听语言变化
    AppLocalizations.languageNotifier.addListener(_onLanguageChanged);
  }
  
  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    AppLocalizations.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }
 
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // 语言改变时重新构建界面
      });
    }
  }
  
  void _onScroll() {
    final currentPosition = widget.scrollController.position.pixels;
    final isScrollingDown = currentPosition > _lastScrollPosition && currentPosition > 50;
    
    if (isScrollingDown != _isScrollingDown) {
      setState(() {
        _isScrollingDown = isScrollingDown;
        if (_isScrollingDown) {
          _isExpanded = false;
        }
      });
    }
    
    _lastScrollPosition = currentPosition;
    
    // Auto-expand when scrolling up
    if (!_isScrollingDown && currentPosition < 50) {
      setState(() {
        _isExpanded = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E4E8)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<EventProvider>(
        builder: (context, provider, _) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF586069)),
              const SizedBox(width: 8),
              _buildUserSearchBox(context, provider),
              const SizedBox(width: 8),
              // Legend expand button
              _buildEventFilter(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollapsedView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E4E8)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.filter_list, size: 16, color: Color(0xFF586069)),
          Consumer<EventProvider>(
            builder: (context, provider, _) {
              return Text(
                provider.userQuery.isNotEmpty 
                  ? '${AppLocalizations.userFilter}${provider.userQuery}'
                  : AppLocalizations.filterUsers,
                style: const TextStyle(fontSize: 12, color: Color(0xFF586069)),
              );
            },
          ),
          const Spacer(),
          _buildEventFilter(),
        ],
      ),
    );
  }

  Expanded _buildUserSearchBox(BuildContext context, EventProvider provider) {
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.filterUsers,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE1E4E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE1E4E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          suffixIcon: provider.userQuery.isNotEmpty // clear user input
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => provider.setUserQuery(''),
              )
            : null,
        ),
        onChanged: provider.setUserQuery,
      ),
    );
  }
  
  Widget _buildLegendToggleButton() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return IconButton(
          icon: const Icon(Icons.filter_alt, size: 18),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.eventTypeFilter),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => provider.setAllEventsSelected(true),
                          child: Text(AppLocalizations.selectAll),
                        ),
                        TextButton(
                          onPressed: () => provider.setAllEventsSelected(false),
                          child: Text(AppLocalizations.deselectAll),
                        ),
                      ],
                    ),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.topicCategories.length,
                    itemBuilder: (context, index) {
                      final entry = provider.topicCategories.entries.elementAt(index);
                      return _buildCategoryDialogItem(entry, provider);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.close),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventFilter() {
    return SizedBox(
      height: 28,
      child: Consumer<EventProvider>(
        builder: (context, provider, _) {
          final children = provider.topicCategories.entries
            .map((entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(entry, provider),
            ))
            .toList();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryChip(MapEntry<String, List<String>> entry, EventProvider provider) {
    final selectedCount = entry.value.where((event) => provider.selectedEventTypes.contains(event)).length;
    final totalCount = entry.value.length;
    
    // Create tooltip message with event descriptions
    final tooltipMessage = entry.value.map((event) {
      final shortName = provider.enumEventShortNames[event] ?? event;
      final description = provider.getEventDescription(event);
      return '$shortName: $description';
    }).join('\n');
    Widget? selectedStatusWidget;
    Color textcolor = (selectedCount == 0)?Colors.grey:Colors.black;
    if (selectedCount < totalCount && selectedCount != 0) {
      selectedStatusWidget = Text(
        '$selectedCount/$totalCount',
        style: TextStyle(
          fontSize: 10,
          color: textcolor,
        ),
      );
    }
    
    return Tooltip(
      message: tooltipMessage,
      preferBelow: false,
      verticalOffset: 10,
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 3),
      child: GestureDetector(
        onTap: () => _showCategoryEventsDialog(entry, provider),
        child: PlainCategoryWidget(category: entry.key, selectedStatusWidget: selectedStatusWidget, textcolor: textcolor),
      ),
    );
  }
  
  Widget _buildCategoryDialogItem(MapEntry<String, List<String>> entry, EventProvider provider) {
    final categoryColor = ColorUtil.getBackGroundColor(context, entry.key);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            AppLocalizations.translate(entry.key),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: entry.value.map((event) => _buildEventCheckbox(event, provider)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildEventCheckbox(String event, EventProvider provider) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedEventTypes.contains(event);
        
        return SizedBox(
          height: 40, // 固定高度，更紧凑
          child: GestureDetector(
            onLongPress: () => _showEventDocumentation(event, provider),
            child: Tooltip(
              message: provider.getEventDescription(event),
              preferBelow: false,
              verticalOffset: 10,
              waitDuration: const Duration(milliseconds: 250),
              showDuration: const Duration(seconds: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        provider.toggleEventType(event);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      provider.enumEventShortNames[event] ?? event,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  
  void _showEventDocumentation(String event, EventProvider provider) {
    final link = provider.eventDocLinks[event] ?? 'https://docs.github.com/en/webhooks/webhook-events-and-payloads';
    final desc = provider.getEventDescription(event);
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.enumEventShortNames[event] ?? event,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final uri = Uri.parse(link);
                    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
                  },
                  child: Text(AppLocalizations.viewDocs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 优化的按钮构建方法
  Widget _buildActionButton(BuildContext context, String text, VoidCallback onPressed, {bool fullWidth = false}) {
    return SizedBox(
      height: 36, // 减小按钮高度
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 16 : 12,
            vertical: 8,
          ),
          minimumSize: Size(fullWidth ? double.infinity : 0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 减小触摸目标大小
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13), // 减小字体大小
        ),
      ),
    );
  }

  void _showCategoryEventsDialog(MapEntry<String, List<String>> entry, EventProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.translate(entry.key)),
        content: Container(
          width: isMobile ? screenWidth * 0.9 : screenWidth * 0.7,
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 移动端优化的按钮布局
              isMobile 
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionButton(
                        context,
                        AppLocalizations.selectAll,
                        () {
                          final eventsToSelect = entry.value.where((event) => !provider.selectedEventTypes.contains(event)).toList();
                          for (final event in eventsToSelect) {
                            provider.toggleEventType(event);
                          }
                          Navigator.pop(context);
                        },
                        fullWidth: true,
                      ),
                      const SizedBox(height: 4),
                      _buildActionButton(
                        context,
                        AppLocalizations.deselectAll,
                        () {
                          final eventsToDeselect = entry.value.where((event) => provider.selectedEventTypes.contains(event)).toList();
                          for (final event in eventsToDeselect) {
                            provider.toggleEventType(event);
                          }
                          Navigator.pop(context);
                        },
                        fullWidth: true,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        context,
                        AppLocalizations.selectAll,
                        () {
                          final eventsToSelect = entry.value.where((event) => !provider.selectedEventTypes.contains(event)).toList();
                          for (final event in eventsToSelect) {
                            provider.toggleEventType(event);
                          }
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        AppLocalizations.deselectAll,
                        () {
                          final eventsToDeselect = entry.value.where((event) => provider.selectedEventTypes.contains(event)).toList();
                          for (final event in eventsToDeselect) {
                            provider.toggleEventType(event);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
              // 事件列表
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: entry.value.map((event) => _buildEventCheckbox(event, provider)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.close),
          ),
        ],
      ),
    );
  }
}