String translateSingleForecast(int weatherCode) {
  const Map<int, String> weatherCodes = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Fog',
    48: 'Depositing rime fog',
    51: 'Drizzle: Light Intensity',
    53: 'Drizzle: Moderate Intensity',
    55: 'Drizzle: Intense',
    56: 'Freezing Drizzle: Light Intensity',
    57: 'Freezing Drizzle: Intense',
    61: 'Rain: Slight intensity',
    63: 'Rain: Moderate',
    65: 'Rain: Heavy',
    66: 'Freezing Rain: Light Intensity',
    67: 'Freezing Rain: Heavy',
    71: 'Snow fall: Slight',
    73: 'Snow fall: Moderate',
    75: 'Snow fall: Heavy',
    77: 'Snow grains',
    80: 'Rain showers: Slight Intensity',
    81: 'Rain showers: Moderate',
    82: 'Rain showers: Violent',
    85: 'Snow showers: slight',
    86: 'Snow showers: heavy',
    95: 'Thunderstorm: Slight or Moderate',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail',
  };

  return weatherCodes[weatherCode] ?? 'Unknown';
}

List<String> translateForecast(List<int> dailyWeatherCode) {
  List<String> forecast = [];
  dailyWeatherCode.forEach((code) {
    forecast.add(translateSingleForecast(code));
  });

  return forecast;
}
