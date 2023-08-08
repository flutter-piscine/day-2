import 'package:flutter/material.dart';
import 'service/geolocator.dart';
import 'service/cities.dart';
import 'autocomplete.dart';

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
  // Create a serviceGeolocator instance
  final ServiceGeolocator serviceGeolocator = ServiceGeolocator();
  final ServiceCities serviceCities = ServiceCities();
  late final TabController _tabController;
  late final TextEditingController _inputController;
  late String searchedTextValue;
  late List<String> displayedCities;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _inputController = TextEditingController();
    searchedTextValue = '';
    displayedCities = [
      'London',
      'Paris',
      'New York',
      'Tokyo',
    ];
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _findCities() async {
    displayedCities = await serviceCities.getCities('London');
  }

  Future<void> _findLocation() async {
    if (await serviceGeolocator.isLocationEnabled()) {
      final position = await serviceGeolocator.getCurrentPosition();
      final latitude = position.latitude.toString();
      final longitude = position.longitude.toString();
      searchedTextValue = '$latitude, $longitude';
      return;
    }
    searchedTextValue = 'Location not enabled';
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
              searchedTextValue = _inputController.text;
            });
          },
        ),
        title: CitiesAutocomplete(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.location_pin),
            tooltip: 'Geolocation',
            onPressed: () {
              setState(() {
                _findLocation();
                // _findCities();
                // _fetchWeather('12.1231', '12.1231');
              });
            },
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // Create a list view of the displayed cities
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Currently"),
                  Text(searchedTextValue),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Today"),
                  Text(searchedTextValue),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Weekly"),
                  Text(searchedTextValue),
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

class AutocompleteExample extends StatefulWidget {
  const AutocompleteExample({super.key});

  static List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  @override
  State<AutocompleteExample> createState() => AutocompleteExampleState();
}

class AutocompleteExampleState extends State<AutocompleteExample> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return AutocompleteExample._kOptions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}
