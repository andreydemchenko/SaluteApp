import 'package:flutter/material.dart';
import 'package:salute/util/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Color? buttonColor;
  final void Function()? onPressed;

  const RoundedButton({super.key, required this.text, this.buttonColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? kAccentColor.withOpacity(0.25),
          padding: EdgeInsets.symmetric(vertical: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: onPressed,
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
