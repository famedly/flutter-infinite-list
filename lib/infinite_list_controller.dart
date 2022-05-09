import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class InfiniteListController<T> {
  final List<T> events;

  final AutoScrollController scrollController;

  T? get centerEvent => _centerEvent;
  T? _centerEvent;

  void setCenterEvent(T item) {
    if (events.contains(item)) {
      _centerEvent = item;
      final pos = isIndexDisplayed(events.indexOf(item), 0);
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

  int get startChildrenCount {
    if (_centerEvent == null && events.isNotEmpty) {
      _centerEvent = events.first; // initial value
    }
    var pos = centerEvent != null ? events.indexOf(centerEvent!) : -1;
    if (pos != -1) {
      return pos;
    }
    _centerEvent = null;
    return 0;
  }

  int get endChildrenCount => events.length - startChildrenCount;

  InfiniteListController({
    T? centerEvent,
    required this.events,
    required this.scrollController,
  }) {
    _centerEvent = centerEvent;
  }

  int getEndIndex(int index) {
    return startChildrenCount + index;
  }

  int getStartIndex(int index) {
    return startChildrenCount - index - 1;
  }

  /// Custom logic to see if thi specific event is in the render view
  double? isIndexDisplayed(int index, double alignment) {
    final ctx = scrollController.tagMap[index]?.context;
    if (ctx == null) return null;

    final renderBox = ctx.findRenderObject()!;
    assert(Scrollable.of(ctx) != null);
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderBox)!;
    final revealedOffset = viewport.getOffsetToReveal(renderBox, alignment);
    return revealedOffset.offset;
  }

  /// Get the last event actually displayed on screen
  T? getLastItemDisplayedOnScreen() {
    T? e;
    for (int i = 0; i < startChildrenCount; i++) {
      final off = isIndexDisplayed(i, 0);
      final event = events[i];

      if (off != null) {
        final delta = off - scrollController.position.pixels;
        if (delta > 0) {
          e = event;
        } else if (e != null) {
          return e;
        }
      }
    }

    for (int i = startChildrenCount; i < events.length; i++) {
      final off = isIndexDisplayed(i, 0);
      if (off != null) {
        final delta = off - scrollController.position.pixels;
        final event = events[i];

        if (delta < 0) {
          e = event;
        } else {
          return e;
        }
      }
    }
    return null;
  }
}
