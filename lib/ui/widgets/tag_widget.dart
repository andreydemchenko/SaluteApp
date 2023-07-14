import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({
    Key? key,
    required this.iconData,
    required this.color,
  }) : super(key: key);
  final IconData iconData;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Icon(
        iconData,
        size: 30,
        color: color,
      )
    );
  }
}