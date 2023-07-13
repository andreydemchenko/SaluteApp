import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:salute/data/db/remote/response.dart';

class FirebaseStorageSource {
  FirebaseStorage instance = FirebaseStorage.instance;

  Future<Response<List<String>>> uploadUserProfilePhotos(
      List<String> paths, String userId) async {
    List<String> downloadUrls = [];
    for (int i = 0; i < paths.length; i++) {
      if (paths[i].isNotEmpty) {
        String userPhotoPath = "user_photos/$userId/photo_$i";

        // Check if the path is a URL or a local file path
        if (Uri.tryParse(paths[i])?.isAbsolute ?? false) {
          downloadUrls.add(paths[i]);
        } else {
          try {
            await instance.ref(userPhotoPath).putFile(File(paths[i]));
            String downloadUrl = await instance.ref(userPhotoPath).getDownloadURL();
            downloadUrls.add(downloadUrl);
          } catch (e) {
            return Response.error(((e as FirebaseException).message ?? e.toString()));
          }
        }
      }
    }
    return Response.success(downloadUrls);
  }

  Future<Response<String>> uploadUserProfilePhoto(
      String filePath, String userId, int photoIndex) async {
    String userPhotoPath = "user_photos/$userId/photo_$photoIndex";

    try {
      await instance.ref(userPhotoPath).putFile(File(filePath));
      String downloadUrl = await instance.ref(userPhotoPath).getDownloadURL();
      return Response.success(downloadUrl);
    } catch (e) {
      return Response.error(((e as FirebaseException).message ?? e.toString()));
    }
  }

  Future<Response<List<String>>> getExistingImages(String userId) async {
    List<String> imageUrls = [];
    for (int i = 0; i < 6; i++) {  // Assuming a maximum of 6 images per user
      String userPhotoPath = "user_photos/$userId/photo_$i";
      try {
        String downloadUrl = await instance.ref(userPhotoPath).getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        if (e is FirebaseException && e.code == 'object-not-found') {
          continue;
        } else {
          return Response.error((e as FirebaseException).message ?? e.toString());
        }
      }
    }
    return Response.success(imageUrls);
  }

  Future<Response<String>> deleteUserProfilePhoto(String userId, int photoIndex) async {
    String userPhotoPath = "user_photos/$userId/photo_$photoIndex";

    try {
      await instance.ref(userPhotoPath).delete();
      return Response.success("Photo deleted successfully");
    } catch (e) {
      return Response.error(((e as FirebaseException).message ?? e.toString()));
    }
  }

}
