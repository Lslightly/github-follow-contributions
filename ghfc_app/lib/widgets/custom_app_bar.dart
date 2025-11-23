import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../utils/localizations.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showLanguageToggle;
  final VoidCallback? onLanguageToggle;

  const CustomAppBar({
    super.key,
    this.showLanguageToggle = true,
    this.onLanguageToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    // 监听语言变化
    AppLocalizations.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF6F8FA),
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GitHub Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.code,
              color: Color(0xFF24292E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Title with gradient effect
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF0969DA), Color(0xFF1F883D)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              AppLocalizations.appTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // This gets overridden by the shader
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Language toggle button
        if (widget.showLanguageToggle)
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF586069)),
            tooltip: '切换语言 / Switch Language',
            onPressed: widget.onLanguageToggle ?? () => _showLanguageDialog(context),
          ),
        // GitHub repository link
        IconButton(
          icon: Image.network(
            'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
            width: 24,
            height: 24,
          ),
          tooltip: 'GitHub Repository',
          onPressed: () {
            final uri = Uri.parse('https://github.com/Lslightly/github-follow-contributions');
            unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择语言 / Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('中文'),
                subtitle: const Text('简体中文'),
                onTap: () {
                  Navigator.pop(context);
                  AppLocalizations.setLanguage('zh');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('语言已切换为中文')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                subtitle: const Text('English (US)'),
                onTap: () {
                  Navigator.pop(context);
                  AppLocalizations.setLanguage('en');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language switched to English')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
}