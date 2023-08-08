import 'package:flutter/material.dart';
import './service/cities.dart';

class CitiesAutocomplete extends StatefulWidget {
  const CitiesAutocomplete({super.key});

  @override
  State<CitiesAutocomplete> createState() => _CitiesAutocompleteState();
}

// WIP: Refactor this widget so it works without static, use AutocompleteExample as reference
class _CitiesAutocompleteState extends State<CitiesAutocomplete> {
  static List<String> _kOptions = <String>[
    'London',
    'Paris',
  ];
  final ServiceCities serviceCities = ServiceCities();

  TextEditingController _textEditingController = TextEditingController();

  Future<void> _findCities(String searchText) async {
    if (searchText.isEmpty || searchText.length < 3) {
      _kOptions = [];
      return;
    }
    print("searching for $searchText");
    _kOptions = await serviceCities.getCities(searchText);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _kOptions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        _textEditingController = textEditingController;
        return TextField(
          controller: textEditingController,
          onChanged: (text) {
            setState(() {
              _findCities(text);
            });
          },
        );
      },
    );
  }
}
