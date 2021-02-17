import 'package:flutter/material.dart';

class ScrollableLayout extends StatelessWidget {
  final Widget child;

  ScrollableLayout({this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints viewportConstraints,
      ) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
