import 'package:firebase_auth/firebase_auth.dart';
import 'package:salute/data/db/remote/response.dart';

class FirebaseAuthSource {
  FirebaseAuth instance = FirebaseAuth.instance;

  Future<Response<UserCredential>> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await instance.signInWithEmailAndPassword(
          email: email, password: password);
      return Response.success(userCredential);
    } catch (e) {
      return Response.error(
          ((e as FirebaseException).message ?? e.toString()));
    }
  }

  Future<Response<UserCredential>> register(String email, String password) async {
    try {
      UserCredential userCredential = await instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return Response.success(userCredential);
    } catch (e) {
      return Response.error(
          ((e as FirebaseException).message ?? e.toString()));
    }
  }

  Future<Response<void>> sendSignInLinkToEmail(
      String email, ActionCodeSettings actionCodeSettings) async {
    try {
      await instance.sendSignInLinkToEmail(email: email, actionCodeSettings: actionCodeSettings);
      return Response.success(null);
    } catch (e) {
      return Response.error(
          ((e as FirebaseException).message ?? e.toString()));
    }
  }

  Future<Response<UserCredential>> signInWithEmailLink(String email, String emailLink) async {
    try {
      UserCredential userCredential = await instance.signInWithEmailLink(email: email, emailLink: emailLink);
      return Response.success(userCredential);
    } catch (e) {
      return Response.error(
          ((e as FirebaseException).message ?? e.toString()));
    }
  }

  Stream<bool> checkEmailVerified() async* {
    User? user = instance.currentUser;

    //while (true) {
      await user?.reload();
      user = instance.currentUser;

      yield user?.emailVerified ?? false;
      await Future.delayed(Duration(seconds: 30));
    //}
  }
}
