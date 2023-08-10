import 'package:flutter/material.dart';
import 'service/geolocator.dart';
import 'service/cities.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  late String cityNameText;
  late String regionText;
  late String countryText;
  late String searchedTextValue;
  late String currentlyViewText;
  late List<List<String>> hourlyViewText;
  late String dailyViewText;
  late List<String> displayedCities;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _inputController = TextEditingController();
    searchedTextValue = '';
    currentlyViewText = '';
    cityNameText = '';
    regionText = '';
    countryText = '';
    hourlyViewText = [
      ['', '', ''],
    ];
    dailyViewText = '';
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

  Future<void> _updateCurrentCity(String suggestion) async {
    final cityName = suggestion.split(' -')[0];
    String latitude = '';
    String longitude = '';
    String region = '';
    String country = '';
    serviceCities.results.forEach((city) {
      if (city['name'] == cityName) {
        latitude = city['latitude'].toString();
        longitude = city['longitude'].toString();
        region = city['region'] ?? 'Unknown';
        country = city['country'];
        return;
      }
    });
    if (latitude == '' || longitude == '') {
      throw Exception('Location not found');
    }
    final weather = await serviceCities.getWeather(latitude, longitude);
    final hourlyWeather =
        await serviceCities.getHourlyWeather(latitude, longitude);

    final currentWeather = weather['current_weather'];

    final formattedCurrentView =
        '${currentWeather['temperature']}°C\n${currentWeather['windspeed']} km/h';
    debugPrint(formattedCurrentView);

    List<String> time = List<String>.from(hourlyWeather['time']);
    List<double> temperature = List<double>.from(hourlyWeather['temperature']);
    List<double> windspeed = List<double>.from(hourlyWeather['windspeed']);

    List<List<String>> formattedHourlyView = [];
    for (int i = 0; i < time.length; i++) {
      String hour = time[i].split('T')[1];
      String temp = '${temperature[i].toString()} °C';
      String windSpeed = '${windspeed[i].toString()} km/h';
      formattedHourlyView.add([hour, temp, windSpeed]);
    }

    setState(() {
      cityNameText = cityName;
      regionText = region;
      countryText = country;
      currentlyViewText = formattedCurrentView;
      hourlyViewText = formattedHourlyView;
    });
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
        title: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _inputController,
              autofocus: true,
              // add a simple style with font 24, text black
              style: const TextStyle(fontSize: 24, color: Colors.black),
              decoration: const InputDecoration(labelText: 'City')),
          suggestionsCallback: (pattern) async {
            return await serviceCities.getCities(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (suggestion) {
            _updateCurrentCity(suggestion);
            setState(() {
              _inputController.text = suggestion;
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.location_pin),
            tooltip: 'Geolocation',
            onPressed: () {
              setState(() {
                // _findLocation();
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
                  Text(cityNameText),
                  Text(regionText),
                  Text(countryText),
                  Text(currentlyViewText),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(cityNameText),
                    Text(regionText),
                    Text(countryText),
                    Column(
                      children: List.generate(
                        hourlyViewText.length,
                        (index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(hourlyViewText[index][0]),
                              Text(hourlyViewText[index][1]),
                              Text(hourlyViewText[index][2]),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
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
