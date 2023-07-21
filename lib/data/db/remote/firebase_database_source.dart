import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/data/db/entity/chat.dart';
import 'package:salute/data/db/entity/match.dart';
import 'package:salute/data/db/entity/message.dart';
import 'package:salute/data/db/entity/swipe_model.dart';

class FirebaseDatabaseSource {
  final FirebaseFirestore instance = FirebaseFirestore.instance;

  void addUser(AppUser user) {
    instance.collection('users').doc(user.id).set(user.toMap());
  }

  void addMatch(String userId, Match match) {
    instance
        .collection('users')
        .doc(userId)
        .collection('matches')
        .doc(match.id)
        .set(match.toMap());
  }

  void addChat(Chat chat) {
    instance.collection('chats').doc(chat.id).set(chat.toMap());
  }

  void addMessage(String chatId, Message message) {
    instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  void addSwipedUser(String userId, SwipeModel swipe) {
    instance
        .collection('users')
        .doc(userId)
        .collection('swipes')
        .doc(swipe.id)
        .set(swipe.toMap());
  }

  void updateUser(AppUser user) async {
    instance.collection('users').doc(user.id).update(user.toMap());
  }

  void updateChat(Chat chat) {
    instance.collection('chats').doc(chat.id).update(chat.toMap());
  }

  void updateMessage(String chatId, String messageId, Message message) {
    instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update(message.toMap());
  }

  Future<DocumentSnapshot> getUser(String userId) {
    return instance.collection('users').doc(userId).get();
  }

  Future<DocumentSnapshot> getSwipe(String userId, String swipeId) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('swipes')
        .doc(swipeId)
        .get();
  }

  Future<QuerySnapshot> getMatches(String userId) {
    return instance.collection('users').doc(userId).collection('matches').get();
  }

  Stream<QuerySnapshot> getMatchesStream(String userId) {
    return instance.collection('users').doc(userId).collection('matches').snapshots();
  }

  Stream<DocumentSnapshot> getChatStream(String chatId) {
    return instance.collection('chats').doc(chatId).snapshots();
  }

  Stream<QuerySnapshot> getPersonsToMatchWith(
      int limit, List<String> ignoreIds) {
    return instance
        .collection('users')
        .where('id', whereNotIn: ignoreIds)
        .limit(limit)
        .snapshots();
  }

  Future<QuerySnapshot> getSwipes(String userId) {
    return instance.collection('users').doc(userId).collection('swipes').get();
  }

  Stream<DocumentSnapshot> observeUser(String userId) {
    return instance.collection('users').doc(userId).snapshots();
  }

  Stream<QuerySnapshot> observeMessages(String chatId) {
    return instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('epoch_time_ms', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> observeChat(String chatId) {
    return instance.collection('chats').doc(chatId).snapshots();
  }
}
