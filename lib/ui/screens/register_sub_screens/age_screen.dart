import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class AgeScreen extends StatefulWidget {
  final Function(int) onChanged;

  const AgeScreen({super.key, required this.onChanged});
  @override
  _AgeScreenState createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int age = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                'age is',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              child: NumberPicker(
                itemWidth: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  value: age,
                  minValue: 10,
                  maxValue: 120,
                  onChanged: (value) => {
                        setState(() {
                          age = value;
                        }),
                        widget.onChanged(value)
                      }),
            ),
          ),
        ),
      ],
    );
  }
}
