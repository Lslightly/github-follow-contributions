
import 'package:flutter/material.dart';

class ColorUtil {
  static Color getBackGroundColor(BuildContext context, String category) {
    switch (category) {
      case 'work':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'discuss':
        return Theme.of(context).colorScheme.secondaryContainer;
      case 'watch':
        return Theme.of(context).colorScheme.tertiaryContainer;
      default:
        return Colors.grey;
    }
  }

  static Color getFrontEndColor(BuildContext context, String category) {
    switch (category) {
      case 'work':
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case 'discuss':
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case 'watch':
        return Theme.of(context).colorScheme.onTertiaryContainer;
      default:
        return Colors.grey;
    }
  }
}

