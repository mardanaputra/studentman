import 'package:flutter/material.dart';

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) compact;
  final Widget Function(BuildContext context, BoxConstraints constraints)? wide;
  final double breakpoint;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.compact,
    this.wide,
    this.breakpoint = 600.0,
  });

  static bool isCompact(BuildContext context, [double breakpoint = 600.0]) {
    return MediaQuery.sizeOf(context).width < breakpoint;
  }

  static bool isWide(BuildContext context, [double breakpoint = 600.0]) {
    return MediaQuery.sizeOf(context).width >= breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint && wide != null) {
          return wide!(context, constraints);
        }
        return compact(context, constraints);
      },
    );
  }
}

