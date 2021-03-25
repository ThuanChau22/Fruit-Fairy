import 'package:flutter/material.dart';

class CustomGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double assistPadding;
  final EdgeInsetsGeometry padding;

  CustomGrid({
    @required this.children,
    @required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.assistPadding = 0.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth - assistPadding * 2;
    widgetWidth /= crossAxisCount;
    double widgetHeight = widgetWidth / childAspectRatio;
    List<List<Widget>> rowList = [];
    children.asMap().forEach((index, widget) {
      if (index % crossAxisCount == 0) {
        rowList.add([]);
      }
      rowList.last.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widgetWidth,
            maxHeight: widgetHeight,
          ),
          child: Padding(
            padding: padding,
            child: widget,
          ),
        ),
      );
    });
    List<Widget> columnList = [];
    rowList.forEach((row) {
      columnList.add(Row(children: row));
    });
    return Column(children: columnList);
  }
}
