//import 'dart:js_interop';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salute/data/db/entity/chat.dart';
import 'package:salute/data/db/remote/firebase_auth_source.dart';
import 'package:salute/data/db/remote/firebase_database_source.dart';
import 'package:salute/data/db/remote/firebase_storage_source.dart';
import 'package:salute/data/db/remote/response.dart';
import 'package:salute/data/model/chat_with_user.dart';
import 'package:salute/data/model/user_registration.dart';
import 'package:salute/util/shared_preferences_utils.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/util/utils.dart';
import 'package:salute/data/db/entity/match.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuthSource _authSource = FirebaseAuthSource();
  final FirebaseStorageSource _storageSource = FirebaseStorageSource();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  bool isLoading = false;
  String? _userId;
  AppUser? _user;

  Future<AppUser?> get user => _getUser();

  Future<Response> loginUser(String email, String password,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.signIn(email, password);
    if (response is Success<UserCredential>) {
      String? id = response.value.user?.uid;
      if (id != null) {
        SharedPreferencesUtil.setUserId(id);
      }
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    return response;
  }

  Future<Response> registerUser(UserRegistration userRegistration,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.register(
        userRegistration.email, userRegistration.password);
    if (response is Success<UserCredential>) {
      String? id = (response).value.user?.uid;
      if (id != null) {
        response = await _storageSource.uploadUserProfilePhotos(
            userRegistration.localProfilePhotoPaths, id);

        if (response is Success<List<String>>) {
          List<String> profilePhotoUrls = response.value;
          AppUser user = AppUser(
              id: id,
              name: userRegistration.name,
              age: userRegistration.age,
              profilePhotoPaths: profilePhotoUrls,
              gender: userRegistration.gender!
          );
          _databaseSource.addUser(user);
          SharedPreferencesUtil.setUserId(id);
          _user = _user;
          return Response.success(user);
        }
      }
    }
    if (response is Error) showSnackBar(errorScaffoldKey, response.message);
    return response;
  }

  Future<AppUser?> _getUser() async {
    if (_user != null) return _user;
    _userId = await SharedPreferencesUtil.getUserId();
    if (_userId != null) {
      _user = AppUser.fromSnapshot(await _databaseSource.getUser(_userId!));
      return _user;
    }
    return null;
  }

  String? get userId => _userId;

  void updateUserProfilePhoto(String localFilePath, int photoIndex,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    isLoading = true;
    notifyListeners();
    Response<dynamic> response = await _storageSource.uploadUserProfilePhoto(localFilePath, _user!.id, photoIndex);
    isLoading = false;
    if (response is Success<String>) {
      _user?.profilePhotoPaths[photoIndex] = response.value;
      _databaseSource.updateUser(_user!);
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    notifyListeners();
  }

  void deleteUserProfilePhoto(int photoIndex,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    isLoading = true;
    notifyListeners();
    Response<dynamic> response = await _storageSource.deleteUserProfilePhoto(_user!.id, photoIndex);
    isLoading = false;
    if (response is Success<String>) {
      _user?.profilePhotoPaths.removeAt(photoIndex);
      _databaseSource.updateUser(_user!);
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    notifyListeners();
  }

  void updateUserBio(String newBio) {
    _user?.bio = newBio;
    _databaseSource.updateUser(_user!);
    notifyListeners();
  }

  void updateUserCity(String newCity) {
    _user?.city = newCity;
    _databaseSource.updateUser(_user!);
    notifyListeners();
  }

  Future<void> updateUserPhotos(List<String> paths) async {
    if (_user != null) {
      Response<dynamic> response = await _storageSource.uploadUserProfilePhotos(
          paths, _user!.id);

      if (response is Success<List<String>>) {
        List<String> profilePhotoUrls = response.value;
        _user!.profilePhotoPaths = profilePhotoUrls;
        _databaseSource.updateUser(_user!);
        notifyListeners();
      }
    }
  }

  Future<void> logoutUser() async {
    _user = null;
    await SharedPreferencesUtil.removeUserId();
  }

  Stream<List<ChatWithUser>> getChatsWithUserStream(String userId) {
    return _databaseSource.getMatchesStream(userId).asyncMap((querySnapshot) async {
      List<ChatWithUser> chatWithUserList = [];

      for (var doc in querySnapshot.docs) {
        Match match = Match.fromSnapshot(doc);
        AppUser matchedUser = AppUser.fromSnapshot(await _databaseSource.getUser(match.id));
        String chatId = compareAndCombineIds(match.id, userId);

        DocumentSnapshot snapshot = await _databaseSource.getChat(chatId);
        if (snapshot.exists) {
          Chat chat = Chat.fromSnapshot(snapshot);
          ChatWithUser chatWithUser = ChatWithUser(chat, matchedUser);
          chatWithUserList.add(chatWithUser);
        }
      }

      return chatWithUserList;
    });
  }

}
