import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? iconData;
  final double iconSize;
  final double paddingReduce;
  final Color? buttonColor;
  final Color? iconColor;
  final String? imageAsset;

  const RoundedIconButton({super.key, 
    required this.onPressed,
    this.iconData,
    this.iconSize = 30,
    this.paddingReduce = 0,
    this.buttonColor,
    this.iconColor,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveIconColor = iconColor ?? Theme.of(context).iconTheme.color ?? Colors.black;

    return MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 0,
      elevation: 5,
      color: buttonColor ?? Theme.of(context).textTheme.labelLarge!.color,
      onPressed: onPressed,
      padding: EdgeInsets.all((iconSize / 2) - paddingReduce),
      shape: CircleBorder(),
      child: iconData != null
          ? Icon(
        iconData,
        size: iconSize,
        color: effectiveIconColor,
      )
          : imageAsset != null
          ? ImageIcon(
        AssetImage(imageAsset!),
        size: iconSize * 1.4,
        color: effectiveIconColor,
      )
          : null,
    );
  }
}