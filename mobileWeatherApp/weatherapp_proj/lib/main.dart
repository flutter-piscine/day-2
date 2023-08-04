import 'package:flutter/material.dart';

/// Flutter code sample for [TabBar].

void main() => runApp(const TabBarApp());

class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const TabBarExample(),
    );
  }
}

class TabBarExample extends StatefulWidget {
  const TabBarExample({super.key});

  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _TabBarExampleState extends State<TabBarExample>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _inputController;
  late String value;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _inputController = TextEditingController();
    value = '';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // An appbar that includes a search TextField and geolocation button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              value = _inputController.text;
            });
          },
        ),
        title: TextField(
          controller: _inputController,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.location_pin),
            tooltip: 'Geolocation',
            onPressed: () {
              setState(() {
                value = 'Geolocation';
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Currently"),
                  Text(value),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Today"),
                  Text(value),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Weekly"),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: 'Currently',
              icon: Icon(Icons.access_time),
            ),
            Tab(
              icon: Icon(Icons.today),
              text: 'Today',
            ),
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Weekly',
            ),
          ],
        ),
      ),
    );
  }
}
