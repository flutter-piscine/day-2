import 'package:flutter/material.dart';
import './service/cities.dart';

class AutocompleteCities extends StatefulWidget {
  const AutocompleteCities({super.key});

  static List<String> _kOptions = <String>[
    'Paris',
    'London',
    'New York',
  ];

  @override
  State<AutocompleteCities> createState() => AutocompleteCitiesState();
}

class AutocompleteCitiesState extends State<AutocompleteCities> {
  final ServiceCities serviceCities = ServiceCities();

  Future<void> _findCities(String searchText) async {
    if (searchText.length > 4) {
      final newOptions = await serviceCities.getCities(searchText);
      debugPrint('New options: $newOptions');
      setState(() {
        AutocompleteCities._kOptions = newOptions;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        // return AutocompleteCities._kOptions;
        return AutocompleteCities._kOptions.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          onChanged: (value) {
            debugPrint('Status changed $value');
            _findCities(value);
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
