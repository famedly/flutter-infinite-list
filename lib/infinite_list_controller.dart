import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class InfiniteListController<T> {
  final List<T> events;
  final AutoScrollController scrollController;

  String? get centerEventId => _centerEvent;
  String? _centerEvent;

  bool allowPopingWhenBottom = false; // by default, new items, won't
  // move the list view. You should set a scroll listener and enable or disable
  // it as needed.

  void setCenterEvent(T item) {
    if (events.firstWhere((e) => getId(item) == getId(e)) != -1) {
      _centerEvent = getId(item);
      final pos = getDistanceToAlignement(events.indexOf(item), 0);
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
    if (_centerEvent == null && events.isNotEmpty || allowPopingWhenBottom) {
      _centerEvent = getId(events.first); // initial value
    }
  }

  int get startChildrenCount {
    _setCenterIfNeeded();

    var pos = _centerEvent != null
        ? events.indexWhere((item) => getId(item) == _centerEvent)
        : -1;
    if (pos != -1) {
      return pos;
    }
    _centerEvent = null;
    return 0;
  }

  int get endChildrenCount => events.length - startChildrenCount;

  InfiniteListController(
      {T? centerEventId,
      required this.events,
      required this.scrollController,
      required this.getId}) {
    if (centerEventId != null) {
      _centerEvent = getId(centerEventId);
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
  double? getDistanceToAlignement(int index, double alignment) {
    final ctx = scrollController.tagMap[index]?.context;
    if (ctx == null) return null;

    final renderBox = ctx.findRenderObject()!;
    assert(Scrollable.of(ctx) != null);
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderBox)!;
    final revealedOffset = viewport.getOffsetToReveal(renderBox, alignment);
    return revealedOffset.offset;
  }

  final String Function(T item) getId;

  /// Get the element closest to the alignement line
  T? getClosestElementToAlignement({double alignment = 0}) {
    T? e;
    for (int i = 0; i < events.length; i++) {
      final off = getDistanceToAlignement(i, alignment);
      final event = events[i];

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
    if (events.isNotEmpty) return events.first;

    return null;
  }
}
