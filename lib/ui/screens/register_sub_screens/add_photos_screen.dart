
import 'package:flutter/material.dart';

import '../../widgets/image_grid_view.dart';
class AddPhotosScreen extends StatefulWidget {
  final Function(List<String>) onPhotosChanged;

  const AddPhotosScreen({super.key, required this.onPhotosChanged});

  @override
  _AddPhotosScreenState createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  List<String> _imagePaths = List.filled(6, '');

  void handleImagePathsChanged(List<String> newImagePaths) {
    _imagePaths = newImagePaths;
    widget.onPhotosChanged(_imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Add photos',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            'Add at least 1 image',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Expanded(
            child: ImageGridView(
              initialImagePaths: List.filled(6, ''),
              onImagePathsChanged: handleImagePathsChanged,
            ),
          ),
        ],
      ),
    );
  }
}
