import 'package:salute/data/db/entity/app_user.dart';

class UserRegistration {
  String name = '';
  int age = 0;
  String email = '';
  String password = '';
  Gender? gender;
  List<String> localProfilePhotoPaths = List.filled(6, '');
}
