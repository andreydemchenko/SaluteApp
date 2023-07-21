import 'package:flutter/material.dart';
import 'package:salute/ui/widgets/bordered_text_field.dart';

import '../../data/model/city.dart';
import '../../services/city_service.dart';
import '../../util/constants.dart';

class CityInputDialog extends StatefulWidget {
  final String labelText;
  final Function(String) onSavePressed;

  CityInputDialog({
    required this.labelText,
    required this.onSavePressed,
  });

  @override
  _CityInputDialogState createState() => _CityInputDialogState();
}

class _CityInputDialogState extends State<CityInputDialog> {
  late Future<List<City>> futureCities;
  String? selectedCity = null;
  final CityService cityService = CityService();
  List<City> cities = [];
  List<City> filteredCities = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCities().then((loadedCities) {
      setState(() {
        cities = loadedCities;
      });
    });
  }

  Future<List<City>> loadCities() async {
    return await cityService.fetchCities();
  }

  void _filterCities() {
    setState(() {
      String query = _textEditingController.text;
      if (query.isEmpty) {
        filteredCities = [];
      } else {
        filteredCities = cities
            .where(
                (city) => city.name.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FractionallySizedBox(
        heightFactor: 0.7,
        child: Column(
            children: [
        Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              BorderedTextField(
                labelText: widget.labelText,
                textController: _textEditingController,
                onChanged: (value) => _filterCities(),
                autoFocus: true,
                keyboardType: TextInputType.text,
              ),
            Text(
              _textEditingController.value.text.isNotEmpty
                  ? 'Select city from the list'
                  : 'Start typing to select your city',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: kBackgroundColor),
            ),
          ])
        ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: filteredCities[index].name,
                              style: TextStyle(color: kSecondaryColor),
                            ),
                            TextSpan(
                              text: ', ${filteredCities[index].subject}',
                              style: TextStyle(color: kAccentColor),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _textEditingController.text =
                            filteredCities[index].name;
                        selectedCity = filteredCities[index].name;
                        setState(() {
                          filteredCities = [];
                        });
                      },
                    );
                  },
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kAccentColor,
                    ),
                    child: Text(
                      'CANCEL',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: kBackgroundColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kColorPrimaryVariant,
                    ),
                    child: Text(
                      'SAVE',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: kPrimaryColor),
                    ),
                    onPressed: () {
                      if (selectedCity != null && _textEditingController.value.text == selectedCity) {
                        widget.onSavePressed(selectedCity!);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              )
            ],
        ),
      ),
    );
  }
}
