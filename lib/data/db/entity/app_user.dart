import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender {
  male,
  female,
}

class AppUser {
  String id = "";
  String name = "";
  int age = 0;
  int profilePhotoIndex = 0;
  String bio = "";
  List<String> profilePhotoPaths = [];
  Gender gender = Gender.male;
  Gender lookingFor = Gender.female;
  String city = "";

  AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.profilePhotoPaths,
    required this.gender
  });

  AppUser.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    name = snapshot['name'];
    age = snapshot['age'];
    profilePhotoIndex = snapshot['profile_photo_index'];
    bio = snapshot.get('bio') ?? '';
    profilePhotoPaths = List<String>.from(snapshot['profile_images_paths'] ?? []);
    gender = parseGender(snapshot['gender']);
    lookingFor = parseGender(snapshot['looking_for']);
    city = snapshot['city'] ?? '';
  }

  Gender parseGender(String genderString) {
    switch (genderString) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  String getGenderString(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
      'profile_photo_index': profilePhotoIndex,
      'bio': bio,
      'profile_images_paths': profilePhotoPaths,
      'gender': getGenderString(gender),
      'looking_for': getGenderString(lookingFor),
      'city': city,
    };
  }
}
