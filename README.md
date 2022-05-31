# Infinite list

A package to have list where you can add item to the bottom and top without making the display move. This is ideal for chat application wanting to load the list view at a specific point.

## Features

This package helps handle infinite list where items can be added to the bottom and the top.
This, without moving the items inside.

Using the [`scroll_to_index`](https://pub.dev/packages/scroll_to_index) package, we support scrolling to a specific index without adding anything.

## Getting started

Add the package to your pubspec.yaml:

```yaml
infinite_list:
scroll_to_index:
 ```

 
 In your dart file, import the library:

 ```Dart
import 'package:infinite_list/infinite_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
 ``` 
 
 Instead of using a `ListView` create a `InfiniteListView` Widget:
 
 ```Dart
  final scrollController = AutoScrollController();
  final infiniteController = InfiniteListControlle0r<T>(
      items: your_list_items
      scrollController: scrollController
  );


  [...]

  InfiniteListView(
    infiniteController: infiniteController,
    itemBuilder: (context, index, itemPosition) => Text(element[index]),
    reversed: false // optional
  ),
```

## Usage

This package define a center element, this element is the one who will be centered and all the element will be position relative to it. The list view is separated in two list view centered on this specific element. Thus when a new element is added before the center element, it will move all element before the new element, up. The contrary if added before the center element.

```
infiniteController.setCenterEvent(item)
```

To allow new element to elements to move the element down (or up if reverse), we need to add new element to the first list and not the second.

For this, we can set 

```
inifiniteController.addNewItemsWhenBottom
```

to true.  So when new items will be added, all the previous item will be moved down (or up if reverse). However, if we scroll a bit, the element will be added to the other list, so won't be imediately displayed. The user will need to scroll to see it.


To know what element is the closest to the beginning or bottom of the visible area.

```
infiniteController.getClosestElementToAlignement(alignment: 0)
```

To get the distance of a specific element to a position of the visible area

```
infiniteController.getDistanceToAlignment(alignment: 0)
```
