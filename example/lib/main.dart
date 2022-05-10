import 'package:flutter/material.dart';
import 'package:infinite_list/infinite_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Infinite list view Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scrollController = AutoScrollController();
  late final InfiniteListController<String> infiniteController;

  List<String> events = ["a", "b", "c", "d", "e", "f", "h", "i"];

  bool reversed = true;

  @override
  void initState() {
    super.initState();

    infiniteController = InfiniteListController(
        events: events,
        scrollController: scrollController,
        getId: (String item) {
          return item;
        });

    scrollController.addListener(scrollListener);
  }

  int lastItem = 0;
  void _addOldItem() {
    const toAdd = 20;
    for (int i = lastItem; i < lastItem + toAdd; i++) {
      events.add("i: $i");
    }
    lastItem += toAdd;
    setState(() {});
  }

  int newItem = -1;
  void _addNewItem() {
    const toAdd = 20;
    for (int i = newItem; i > newItem - toAdd; i--) {
      events.insert(0, "i: $i");
    }
    newItem -= toAdd;
    setState(() {});
  }

  String? lastElement;
  void scrollListener() {
    final el = infiniteController.getLastItemDisplayedOnScreen();

    if (el != lastElement) {
      setState(() {
        lastElement = el;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        InfiniteListView<String>(
            infiniteController: infiniteController,
            reversed: reversed,
            itemBuilder: (int index, ItemPositions position) {
              switch (position) {
                case ItemPositions.start:
                  return const Text("Start");
                case ItemPositions.item:
                  return ListTile(
                      onTap: () {
                        infiniteController.setCenterEvent(events[index]);
                        setState(() {});
                      },
                      title: Text(events[index]));

                case ItemPositions.end:
                  return const Text("End");
              }
            }),
        Positioned(
            right: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: reversed ? _addOldItem : _addNewItem,
            )),
        Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: reversed ? _addNewItem : _addOldItem,
            )),
        Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  events.clear();
                  lastItem = 0;
                  newItem = -1;
                });
              },
            )),
        Positioned(
            right: 80,
            bottom: 20,
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(lastElement ?? ''),
            ))),
        Positioned(
            left: 20,
            top: 80,
            child: IconButton(
              icon: const Icon(Icons.swipe),
              onPressed: () {
                //infiniteController.switchStart();
              },
            ))
      ],
    ));
  }
}
