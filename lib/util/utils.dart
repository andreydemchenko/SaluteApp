
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showSnackBar(GlobalKey<ScaffoldState> globalKey, String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(globalKey.currentContext!).hideCurrentSnackBar();
    ScaffoldMessenger.of(globalKey.currentContext!).showSnackBar(snackBar);
  });
}

String compareAndCombineIds(String userID1, String userID2) {
  if (userID1.compareTo(userID2) < 0) {
    return userID2 + userID1;
  } else {
    return userID1 + userID2;
  }
}

String convertEpochMsToDateTime(DateTime dateTime) {
  int oneDayInMs = 86400000;
  int epochMs = dateTime.millisecondsSinceEpoch;
  var date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  int currentTimeMs = DateTime.now().millisecondsSinceEpoch;
  if ((currentTimeMs - epochMs) >= oneDayInMs) {
    return '${DateFormat.MMMd().format(date)}  ${DateFormat.Hm().format(date)}';
  } else {
    return DateFormat.Hm().format(date);
  }
}
