library infinite_list_view;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

enum itemPosition { start, item, end }

/// A list controller.
/// By default, the item are added in the second list
class InfiniteListView<T> extends StatelessWidget {
  const InfiniteListView(
      {Key? key,
      required this.itemBuilder,
      required this.infiniteController,
      this.reversed = false})
      : super(key: key);

  final Widget Function(int index, itemPosition position) itemBuilder;
  final InfiniteListViewController<T> infiniteController;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey('second-sliver-list');

    return CustomScrollView(
        reverse: reversed,
        center: centerKey,
        controller: infiniteController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
            var position = itemPosition.item;
            late Key key;
            if (index == 0) {
              if (infiniteController.startChildrenCount == 0 ||
                  infiniteController.endChildrenCount != 0) return Container();
              position = itemPosition.end;
              key = const Key("startlist_end");
            } else if (index == infiniteController.startChildrenCount + 1) {
              // if we don't have element, the main list view will display the start element
              if (infiniteController.startChildrenCount == 0) {
                return Container();
              }

              position = itemPosition.start;
              key = const Key("startlist_start");
            } else {
              index = infiniteController.getStartIndex(index - 1);
              key = ValueKey(index);
            }
            return AutoScrollTag(
              key: key,
              controller: infiniteController.scrollController,
              index: index,
              child: itemBuilder(index, position),
            );
          },
                  childCount: infiniteController.startChildrenCount + 2,
                  addAutomaticKeepAlives: true)),
          SliverList(
            // Key parameter makes this list grow bottom
            key: centerKey,
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              var position = itemPosition.item;

              late Key key;
              if (index == 0) {
                if (infiniteController.startChildrenCount != 0) {
                  return Container();
                }
                position = itemPosition.start;
                key = const Key("endlist_start");
              } else if (index == infiniteController.endChildrenCount + 1) {
                position = itemPosition.end;
                key = const Key("endlist_end");
              } else {
                index = infiniteController.getEndIndex(index - 1);
                key = ValueKey(index);
              }
              return AutoScrollTag(
                key: key,
                controller: infiniteController.scrollController,
                index: index,
                child: Container(
                  color: Colors.red,
                  child: itemBuilder(index, position),
                ),
              );
            },
                childCount: infiniteController.endChildrenCount + 2,
                addAutomaticKeepAlives: true),
          )
        ]);
  }
}

class InfiniteListViewController<T> {
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

  InfiniteListViewController({
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
}
