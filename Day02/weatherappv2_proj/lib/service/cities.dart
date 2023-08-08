import 'dart:convert';
import 'package:http/http.dart' as http;

// set a service to get cities from api

class ServiceCities {
  late List<Map<String, dynamic>> results;

  Future<Map<String, double>> getWeather(
      String latitude, String longitude) async {
    final encodedLatitude = Uri.encodeQueryComponent(latitude);
    final encodedLongitude = Uri.encodeQueryComponent(longitude);
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$encodedLatitude&longitude=$encodedLongitude&current_weather=true';
    print(apiUrl);
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['current_weather'].isEmpty) {
        throw Exception('Location not found');
      }
      final temperature = data['current_weather']['temperature'];
      return {'temperature': temperature};
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<List<dynamic>> _getCityResults(String cityName) async {
    final encodedCityName = Uri.encodeQueryComponent(cityName);
    final apiUrl =
        'https://geocoding-api.open-meteo.com/v1/search?name=$encodedCityName&count=2&language=en&format=json';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isEmpty) {
        throw Exception('Location not found');
      }
      return data['results'];
    }
    throw Exception('Failed to fetch data');
  }

  Future<List<String>> getCities(String cityName) async {
    if (cityName.isEmpty || cityName.length < 3) {
      return [];
    }
    try {
      final tempResults = await _getCityResults(cityName);
      if (tempResults.isEmpty) {
        throw Exception('Location not found');
      }

      results = tempResults.map((result) {
        return {
          'name': result['name'],
          'region': result['admin2'],
          'country': result['country'],
          'latitude': result['latitude'],
          'longitude': result['longitude'],
        };
      }).toList();

      List<String> cities = results.map((result) {
        return '${result['name']}, ${result['region']} - ${result['country']}';
      }).toList();
      // Replace null as unknown
      cities = cities.map((city) {
        return city.replaceAll('null', 'Unknown');
      }).toList();
      return cities;
    } catch (e) {
      throw e;
    }
  }
}
