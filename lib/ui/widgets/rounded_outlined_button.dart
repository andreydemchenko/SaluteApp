import 'package:flutter/material.dart';
import 'package:salute/util/constants.dart';

class RoundedOutlinedButton extends StatelessWidget {
  final String text;
  final Color? buttonColor;
  final void Function()? onPressed;

  const RoundedOutlinedButton({super.key, required this.text, this.buttonColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor ?? kSecondaryColor, width: 2.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: onPressed,
        child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: buttonColor ?? kSecondaryColor)),
      ),
    );
  }

}
