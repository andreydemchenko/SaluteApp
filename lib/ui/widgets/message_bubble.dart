import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/util/utils.dart';

class MessageBubble extends StatelessWidget {
  final DateTime epochTimeMs;
  final String text;
  final bool isSenderMyUser;
  final bool includeTime;

  const MessageBubble(
      {super.key, required this.epochTimeMs,
      required this.text,
      required this.isSenderMyUser,
      required this.includeTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isSenderMyUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          includeTime
              ? Opacity(
                  opacity: 0.4,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(convertEpochMsToDateTime(epochTimeMs),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14, fontWeight: FontWeight.normal)),
                  ),
                )
              : Container(),
          SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Material(
              borderRadius: BorderRadius.circular(8.0),
              elevation: 5.0,
              color: isSenderMyUser ? kAccentColor : kBlueColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSenderMyUser ? kPrimaryColor : Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
