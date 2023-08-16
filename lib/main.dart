import 'package:flutter/material.dart';
import 'package:weatherappv2_proj/utils/views.dart';
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
  late List<List<String>> dailyViewText;
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
      ['', '', '', ''],
    ];
    dailyViewText = [
      ['', '', '', ''],
    ];
    ;
    displayedCities = [
      'London',
      'Paris',
      'New York',
      'Tokyo',
    ];
    _findLocation();
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

      if (latitude == '' || longitude == '') {
        throw Exception('Location not found');
      }
      final weather = await serviceCities.getWeather(latitude, longitude);
      final hourlyWeather =
          await serviceCities.getHourlyWeather(latitude, longitude);

      setState(() {
        cityNameText = 'Sao Paulo';
        regionText = 'Sao Paulo';
        countryText = 'Brazil';
        currentlyViewText = formatCurrentView(weather['current_weather']);
        hourlyViewText = formatHourlyView(hourlyWeather);
        dailyViewText = formatDailyView(weather['daily']);
      });
      return;
    }
    setState(() {
      cityNameText =
          'Geolocation is not available, please enable it in your App settings';
    });
  }

  Future<void> _updateCurrentCity(String suggestion) async {
    final elements = suggestion.split(' - ');
    final cityName = elements[0];
    String latitude = '';
    String longitude = '';
    String region = elements[1];
    String country = elements[2];
    serviceCities.results.forEach((city) {
      if (city['name'] == cityName && city['region'] == region) {
        latitude = city['latitude'].toString();
        longitude = city['longitude'].toString();
        return;
      }
    });
    if (latitude == '' || longitude == '') {
      throw Exception('Location not found');
    }
    final weather = await serviceCities.getWeather(latitude, longitude);
    final hourlyWeather =
        await serviceCities.getHourlyWeather(latitude, longitude);

    setState(() {
      cityNameText = cityName;
      regionText = region;
      countryText = country;
      currentlyViewText = formatCurrentView(weather['current_weather']);
      hourlyViewText = formatHourlyView(hourlyWeather);
      dailyViewText = formatDailyView(weather['daily']);
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
              decoration: const InputDecoration(labelText: 'Search location')),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
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
                                Expanded(child: Text(hourlyViewText[index][0])),
                                Expanded(child: Text(hourlyViewText[index][1])),
                                Expanded(child: Text(hourlyViewText[index][2])),
                                Expanded(child: Text(hourlyViewText[index][3])),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
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
                          dailyViewText.length,
                          (index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: Text(dailyViewText[index][0])),
                                Expanded(child: Text(dailyViewText[index][1])),
                                Expanded(child: Text(dailyViewText[index][2])),
                                Expanded(child: Text(dailyViewText[index][3])),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
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
