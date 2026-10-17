import 'package:flutter/widgets.dart';

enum ScreenSize {
  compact,
  medium,
  expanded;

  static ScreenSize fromWidth(double width) {
    if (width > 1024) return expanded;
    if (width >= 600) return medium;
    return compact;
  }

  static ScreenSize of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }
}
