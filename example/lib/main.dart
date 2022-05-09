import 'package:flutter/material.dart';
import 'package:infinite_list_view/infinite_list_view.dart';
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
  late final InfiniteListViewController<String> infiniteController;

  List<String> events = [];

  @override
  void initState() {
    super.initState();

    infiniteController = InfiniteListViewController(
        events: events, scrollController: scrollController);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        InfiniteListView<String>(
            infiniteController: infiniteController,
            reversed: true,
            itemBuilder: (int index, itemPosition position) {
              switch (position) {
                case itemPosition.start:
                  return const Text("Start");
                case itemPosition.item:
                  return ListTile(
                      onTap: () {
                        infiniteController.setCenterEvent(events[index]);
                        setState(() {});
                      },
                      title: Text(events[index]));

                case itemPosition.end:
                  return const Text("End");
              }
            }),
        Positioned(
            right: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: _addNewItem,
            )),
        Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: _addOldItem,
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
