import 'package:cloud_firestore/cloud_firestore.dart';

enum Swipe { left, right, none }

class SwipeModel {
  String id = "";
  bool liked = false;

  SwipeModel(this.id, this.liked);

  SwipeModel.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    liked = snapshot['liked'];
  }
  SwipeModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    liked = map['liked'];
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'liked': liked};
  }
}
