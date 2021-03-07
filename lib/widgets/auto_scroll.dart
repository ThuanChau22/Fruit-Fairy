import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class AutoScroll<T> {
  final AutoScrollController _scrollController = AutoScrollController();
  final Map<T, int> elements;

  AutoScroll({@required this.elements});

  AutoScrollController get controller {
    return this._scrollController;
  }

  Widget wrap({
    @required T tag,
    @required Widget child,
  }) {
    return AutoScrollTag(
      index: elements[tag],
      key: ValueKey(tag),
      controller: _scrollController,
      child: child,
    );
  }

  Future<void> scroll(T tag) async {
    await _scrollController.scrollToIndex(
      elements[tag],
      duration: Duration(seconds: 1),
      preferPosition: AutoScrollPosition.begin,
    );
  }
}
