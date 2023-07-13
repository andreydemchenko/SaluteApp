import 'package:flutter/material.dart';

class AppIconTitle extends StatelessWidget {
  const AppIconTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32.0,
            height: 32.0,
            child: Image.asset('images/tinder_icon.png'),
          ),
          SizedBox(width: 5.0),
          Text(
            'lorem',
            style: Theme.of(context).textTheme.displayMedium,
          )
        ],
      ),
    );
  }
}