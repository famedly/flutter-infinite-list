import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class InfiniteListController<T> {
  final List<T> items;
  final AutoScrollController scrollController;

  T? get centerEventId => _centerEvent;
  T? _centerEvent;

  /// Control if new items will be added to the upper list when scrolled to bottom.
  /// This will have the consequences to bring the element into view imediately.
  /// If false, the element will be added on the bottom list and the user will
  /// need to scroll to see the new element.
  bool disableSecondList = false;

  void setCenterEvent(T item) {
    if (items.contains(item)) {
      _centerEvent = item;
      final pos = getDistanceToAlignment(items.indexOf(item), 0);
      if (pos != null) {
        var delta = scrollController.position.pixels - pos;
        if (startChildrenCount == 0) {
          delta = 0; // prevent the bouncing annimation
          // when trying to reset to the last item
        }
        scrollController.jumpTo(delta);
      }
    }
  }

  void _setCenterIfNeeded() {
    if (_centerEvent == null && items.isNotEmpty || disableSecondList) {
      _centerEvent = items.first; // initial value
    }
  }

  int get startChildrenCount {
    _setCenterIfNeeded();

    var pos = _centerEvent != null
        // ignore: null_check_on_nullable_type_parameter
        ? items.indexOf(_centerEvent!)
        : -1;
    if (pos != -1) {
      return pos;
    }
    _centerEvent = null;
    return 0;
  }

  int get endChildrenCount => items.length - startChildrenCount;

  InfiniteListController(
      {T? centerEventId, required this.items, required this.scrollController}) {
    if (centerEventId != null) {
      _centerEvent = centerEventId;
    }
    _setCenterIfNeeded();
  }

  int getEndIndex(int index) {
    return startChildrenCount + index;
  }

  int getStartIndex(int index) {
    return startChildrenCount - index - 1;
  }

  /// Get the distance between the alignement line and the actual element.
  double? getDistanceToAlignment(int index, double alignment) {
    final ctx = scrollController.tagMap[index]?.context;
    if (ctx == null) return null;

    final renderBox = ctx.findRenderObject()!;
    assert(Scrollable.of(ctx) != null);
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderBox)!;
    final revealedOffset = viewport.getOffsetToReveal(renderBox, alignment);
    return revealedOffset.offset;
  }

  /// Get the element closest to the alignement line
  T? getClosestElementToAlignment({double alignment = 0}) {
    T? e;
    for (int i = 0; i < items.length; i++) {
      final off = getDistanceToAlignment(i, alignment);
      final event = items[i];

      if (off != null) {
        final delta = off - scrollController.position.pixels;
        if (delta < 0) {
          e = event;
        } else if (e != null) {
          return e;
        }
      }
    }

    // we didn't found one, we may have reached the bottom
    if (items.isNotEmpty) return items.first;

    return null;
  }
}
