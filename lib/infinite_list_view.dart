import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'infinite_list_controller.dart';

enum ItemPositions { start, item, end }

/// A list controller.
/// By default, the item are added in the second list
class InfiniteListView extends StatelessWidget {
  const InfiniteListView(
      {Key? key,
      required this.itemBuilder,
      required this.infiniteController,
      this.reversed = false})
      : super(key: key);

  final Widget Function(BuildContext context, int index, ItemPositions position) itemBuilder;
  final InfiniteListController infiniteController;
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
            var position = ItemPositions.item;
            late Key key;
            if (index == 0) {
              if (infiniteController.startChildrenCount == 0 ||
                  infiniteController.endChildrenCount != 0) return Container();
              position = ItemPositions.end;
              key = const Key("startlist_end");
            } else if (index == infiniteController.startChildrenCount + 1) {
              // if we don't have element, the main list view will display the start element
              if (infiniteController.startChildrenCount == 0) {
                return Container();
              }

              position = ItemPositions.start;
              key = const Key("startlist_start");
            } else {
              index = infiniteController.getStartIndex(index - 1);
              key = ValueKey(index);
            }
            return AutoScrollTag(
              key: key,
              controller: infiniteController.scrollController,
              index: index,
              child: itemBuilder(context, index, position),
            );
          },
                  childCount: infiniteController.startChildrenCount + 2,
                  addAutomaticKeepAlives: true)),
          SliverList(
            // Key parameter makes this list grow bottom
            key: centerKey,
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              var position = ItemPositions.item;

              late Key key;
              if (index == 0) {
                if (infiniteController.startChildrenCount != 0) {
                  return Container();
                }
                position = ItemPositions.start;
                key = const Key("endlist_start");
              } else if (index == infiniteController.endChildrenCount + 1) {
                position = ItemPositions.end;
                key = const Key("endlist_end");
              } else {
                index = infiniteController.getEndIndex(index - 1);
                key = ValueKey(index);
              }
              return AutoScrollTag(
                key: key,
                controller: infiniteController.scrollController,
                index: index,
                child: itemBuilder(context, index, position),
              );
            },
                childCount: infiniteController.endChildrenCount + 2,
                addAutomaticKeepAlives: true),
          )
        ]);
  }
}
