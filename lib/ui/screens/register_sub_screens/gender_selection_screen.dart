import 'package:flutter/material.dart';

import '../../../data/db/entity/app_user.dart';

class GenderSelectionScreen extends StatefulWidget {
  final Function(Gender) onChanged;

  const GenderSelectionScreen({super.key, required this.onChanged});
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  Gender? _selectedGender;

  void _handleGenderSelection(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onChanged(gender);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select gender',
          style: Theme
              .of(context)
              .textTheme
              .displaySmall,
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => _handleGenderSelection(Gender.male),
              child: Card(
                color: _selectedGender == Gender.male
                    ? Colors.blue[200]
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: const <Widget>[
                      Icon(
                        Icons.male,
                        size: 80,
                      ),
                      Text(
                        "Male",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _handleGenderSelection(Gender.female),
              child: Card(
                color: _selectedGender == Gender.female
                    ? Colors.pink[200]
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: const <Widget>[
                      Icon(
                        Icons.female,
                        size: 80,
                      ),
                      Text(
                        "Female",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Spacer()
      ],
    );
  }
}
