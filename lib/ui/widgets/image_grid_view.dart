import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salute/ui/widgets/rounded_icon_button.dart';

import '../../util/constants.dart';
import 'image_portrait.dart';

class ImageGridView extends StatefulWidget {
  final List<String> initialImagePaths;
  final ValueChanged<List<String>> onImagePathsChanged;

  const ImageGridView({
    Key? key,
    required this.onImagePathsChanged,
    required this.initialImagePaths,
  }) : super(key: key);

  @override
  _ImageGridViewState createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  final picker = ImagePicker();
  late List<String> _imagePaths;

  @override
  void initState() {
    super.initState();
    _imagePaths = List<String>.filled(6, '', growable: false);
    for (var i = 0; i < _imagePaths.length; i++) {
      if (i < widget.initialImagePaths.length) {
        _imagePaths[i] = widget.initialImagePaths[i];
      }
    }
  }

  Future pickImageFromGallery(int index) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePaths[index] = pickedFile.path;
      });
      widget.onImagePathsChanged(_imagePaths);
    }
  }

  void removeImage(int index) {
    setState(() {
      _imagePaths[index] = '';
    });
    widget.onImagePathsChanged(_imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width / 3 - 10;
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 3 / 4,
      children: List.generate(6, (index) {
        return ImagePortrait(
          imageType: _imagePaths[index].isEmpty
              ? ImageType.NONE
              : _imagePaths[index].startsWith("http") ? ImageType.NETWORK_IMAGE : ImageType.FILE_IMAGE,
          imagePath: _imagePaths[index].isEmpty ? null : _imagePaths[index],
          width: containerWidth,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: RoundedIconButton(
                iconData: _imagePaths[index].isEmpty ? Icons.add : Icons.remove,
                iconSize: 18,
                buttonColor: kAccentColor,
                onPressed: () => _imagePaths[index].isEmpty
                    ? pickImageFromGallery(index)
                    : removeImage(index),
              ),
            ),
          ),
        );
      }),
    );
  }
}
