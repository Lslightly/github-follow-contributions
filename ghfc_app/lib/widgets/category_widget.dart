
import 'package:flutter/material.dart';
import 'package:ghfc_app/utils/color.dart';
import 'package:ghfc_app/utils/localizations.dart';

class PlainCategoryWidget extends StatelessWidget {
  final String category;
  final Color? textcolor;
  final Widget? selectedStatusWidget;

  const PlainCategoryWidget({
    super.key,
    required this.category,
    this.selectedStatusWidget,
    this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorUtil.getBackGroundColor(context, category);
    final textWidget = Text(
      AppLocalizations.category(category),
      style: TextStyle(
        color: textcolor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    List<Widget> childrens = [textWidget];
    if (selectedStatusWidget != null) {
      childrens.add(selectedStatusWidget!);
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: backgroundColor,
            width: 1,
          )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: childrens,
        ),
      );
  }
}