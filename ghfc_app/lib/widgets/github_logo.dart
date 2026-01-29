import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GitHubLogo extends StatefulWidget {
  final double size;
  final Color? color;
  
  const GitHubLogo({
    Key? key,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  State<GitHubLogo> createState() => _GitHubLogoState();
}

class _GitHubLogoState extends State<GitHubLogo> {
  bool _useLocalAsset = true;
  
  @override
  Widget build(BuildContext context) {
    if (_useLocalAsset) {
      return Image.asset(
        'assets/github_logo.png',
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          // 如果本地资源加载失败，使用图标替代
          return Icon(
            Icons.code,
            size: widget.size,
            color: widget.color ?? const Color(0xFF586069),
          );
        },
      );
    } else {
      // 作为备用方案，使用网络图片
      return Image.network(
        'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          // 网络图片也失败时，使用图标
          return Icon(
            Icons.code,
            size: widget.size,
            color: widget.color ?? const Color(0xFF586069),
          );
        },
      );
    }
  }
}