import 'package:flutter/material.dart';
import 'package:salute/util/constants.dart';
import 'dart:io';

enum ImageType { ASSET_IMAGE, FILE_IMAGE, NETWORK_IMAGE, NONE }

class ImagePortrait extends StatelessWidget {
  final double width;
  final String? imagePath;
  final ImageType imageType;
  final Widget? child;

  const ImagePortrait({super.key, 
    required this.imageType,
    required this.imagePath,
    this.width = 200.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.all(8.0),
          width: width,
          height: width * 4 / 3,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: kAccentColor),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: EdgeInsets.all(imageType == ImageType.NONE ? 20.0 : 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
              child: ColorFiltered(
                colorFilter: imageType == ImageType.NONE
                    ? ColorFilter.mode(Colors.blueGrey, BlendMode.srcATop)
                    : ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: getImageProvider(),
                      fit: imageType == ImageType.NONE
                          ? BoxFit.contain
                          : BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (child != null)
          Positioned(
            right: -10,
            bottom: -10,
            child: child!,
          ),
      ],
    );
  }

  Widget builds(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.all(8.0),
          width: width,
          height: width * 4 / 3,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: kAccentColor),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            image: DecorationImage(
              image: getImageProvider(),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        if (child != null)
          Positioned(
            right: -10,
            bottom: -10,
            child: child!,
          ),
      ],
    );
  }

  ImageProvider getImageProvider() {
    switch (imageType) {
      case ImageType.FILE_IMAGE:
        return FileImage(File(imagePath!));

      case ImageType.ASSET_IMAGE:
        return AssetImage(imagePath!);
      case ImageType.NETWORK_IMAGE:
        return NetworkImage(imagePath!);
      case ImageType.NONE:
        return AssetImage('images/fallback_image.png');
    }
  }
}
