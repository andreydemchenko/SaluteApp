//import 'dart:js_interop';

import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
       // if (response.value.user!.emailVerified) {
          SharedPreferencesUtil.setUserId(id);
        // } else {
        //   showSnackBar(errorScaffoldKey, "Please verify your email before logging in.");
        //   return Response.error("Email not verified.");
        // }
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

  /*Future<Response> registerUser(UserRegistration userRegistration,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.register(
        userRegistration.email, userRegistration.password);
    if (response is Success<UserCredential>) {
      String? id = (response).value.user?.uid;
      if (id != null) {
        Response<dynamic> verifyResponse = await _authSource
            .sendEmailVerification(response.value.user!);
        if (verifyResponse is Error) {
          showSnackBar(errorScaffoldKey, verifyResponse.message);
        } else {
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
    }
    if (response is Error) showSnackBar(errorScaffoldKey, response.message);
    return response;
  }*/

  String? _emailLink;

  Future<void> retrieveDynamicLink() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDynamicLink(data);
  }

  void _handleDynamicLink(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      _emailLink = deepLink.toString();
      notifyListeners();  // optional
    }
  }

  Future<Response> sendVerificationLink(String email) async {
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://demdev.page.link/verify',
      handleCodeInApp: true,
      androidPackageName: 'com.demdev.salute',
      androidInstallApp: true,
      androidMinimumVersion: '12',
      iOSBundleId: 'com.demdev.salute',
    );

    Response<dynamic> response = await _authSource.sendSignInLinkToEmail(
        email, actionCodeSettings);
    SharedPreferencesUtil.setUserId(email);
    return response;
  }

  void confirmEmailLink(UserRegistration userRegistration, GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.signInWithEmailLink(userRegistration.email, _emailLink!);
    if (response is Success<UserCredential>) {
      Response passwordResponse = await updatePassword(userRegistration.password);
      if (passwordResponse is Success<User>) {
        _completeRegistration(userRegistration, errorScaffoldKey);
      } else if (passwordResponse is Error) {
        showSnackBar(errorScaffoldKey, passwordResponse.message);
      }
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
  }

  Future<Response> updatePassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(password);
      return Response.success(user);
    } catch (e) {
      return Response.error(((e as FirebaseException).message ?? e.toString()));
    }
  }

  void _completeRegistration(UserRegistration userRegistration, GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.register(
        userRegistration.email, userRegistration.password);

    if (response is Success<UserCredential>) {
      String? id = response.value.user?.uid;
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
        }
      }
    }
    if (response is Error) showSnackBar(errorScaffoldKey, response.message);
  }

  StreamSubscription<bool>? emailVerificationSubscription;
  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  void startCheckingEmailVerified(UserRegistration userRegistration, GlobalKey<ScaffoldState> errorScaffoldKey) {
    emailVerificationSubscription = _authSource.checkEmailVerified().listen((isEmailVerified) {
      if (isEmailVerified) {
        emailVerificationSubscription?.cancel();
        _isEmailVerified = isEmailVerified;
        notifyListeners();
        _completeRegistration(userRegistration, errorScaffoldKey);
      }
    });
  }

  @override
  void dispose() {
    emailVerificationSubscription?.cancel();
    super.dispose();
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
    return _databaseSource.getMatchesStream(userId).switchMap((querySnapshot) async* {
      List<Stream<ChatWithUser>> chatWithUsers = [];
      for (var doc in querySnapshot.docs) {
        Match match = Match.fromSnapshot(doc);
        AppUser matchedUser = await _databaseSource.getUser(match.id).then((snapshot) => AppUser.fromSnapshot(snapshot));
        String chatId = compareAndCombineIds(match.id, userId);
        chatWithUsers.add(_databaseSource.getChatStream(chatId).map((snapshot) => ChatWithUser(Chat.fromSnapshot(snapshot), matchedUser)));
      }

      // Listen to all chat streams at once
      yield* StreamGroup.merge<ChatWithUser>(chatWithUsers).scan((List<ChatWithUser> accumulator, ChatWithUser value, int index) {
        // Search for existing chat with user
        final existingChatWithUser = accumulator.firstWhereOrNull((chatWithUser) => chatWithUser.chat.id == value.chat.id);

        if (existingChatWithUser == null) {
          // If not exists, add new chat with user
          accumulator.add(value);
        } else {
          // If exists, update the existing chat
          final existingIndex = accumulator.indexOf(existingChatWithUser);
          accumulator[existingIndex] = value;
        }

        return accumulator;
      }, []);
    });
  }

}
