

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salute/data/db/entity/app_user.dart';

import '../../data/db/entity/chat.dart';
import '../../data/db/entity/message.dart';
import '../../data/db/remote/firebase_database_source.dart';
import '../../util/constants.dart';
import '../widgets/chat_top_bar.dart';
import '../widgets/message_bubble.dart';


class ChatScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  final messageTextController = TextEditingController();

  static const String id = 'chat_screen';

  final String chatId;
  final String myUserId;
  final String otherUserId;

  ChatScreen(
      {super.key, required this.chatId,
      required this.myUserId,
      required this.otherUserId});

  void checkAndUpdateLastMessageSeen(
      Message lastMessage, String messageId, String myUserId) {
    if (lastMessage.seen == false && lastMessage.senderId != myUserId) {
      lastMessage.seen = true;
      Chat updatedChat = Chat(chatId, lastMessage);

      _databaseSource.updateChat(updatedChat);
      _databaseSource.updateMessage(chatId, messageId, lastMessage);
    }
  }

  bool shouldShowTime(Message currMessage, Message? messageBefore) {
    int halfHourInMilli = 1800000;

    if (messageBefore != null) {
      if ((messageBefore.epochTimeMs - currMessage.epochTimeMs).abs() >
          halfHourInMilli) {
        return true;
      }
    }
    return messageBefore == null;
  }

  List<Message> generateExactTimeMockMessages({required String myUserId}) {
    final List<Message> messages = [];

    final List<String> mockTexts = [
      'Hello, how are you?',
      'I am fine, thank you!',
      'Great to hear!',
      'Where are you now?',
      'I am at home.',
      'How about you?',
      'I am at work.',
      'Oh, busy day?',
      'Yes, a bit.',
      'Okay, take care!',
    ];

    // List of exact times for testing in format yyyy-MM-dd – kk:mm
    final List<String> exactTimes = [
      '2023-07-07 – 15:30',
      '2023-07-08 – 15:32',
      '2023-07-08 – 15:34',
      '2023-07-08 – 15:36',
      '2023-07-08 – 15:38',
      '2023-07-08 – 15:40',
      '2023-07-08 – 15:42',
      '2023-07-08 – 15:44',
      '2023-07-08 – 19:46',
      '2023-07-09 – 15:48',
    ];

    // convert string time to epoch
    final epochTimes = exactTimes.map((time) {
      final format = DateFormat('yyyy-MM-dd – kk:mm');
      return format.parse(time).millisecondsSinceEpoch;
    }).toList();

    for (var i = 0; i < mockTexts.length; i++) {
      final senderId = i % 2 == 0 ? myUserId : 'otherUser';
      final text = mockTexts[i];
      final epochTimeMs = epochTimes[i];
      const seen = false;

      final message = Message(epochTimeMs, seen, senderId, text);
      messages.add(message);
    }

    // Ensure messages are ordered by time
    messages.sort((a, b) => b.epochTimeMs.compareTo(a.epochTimeMs));

    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _databaseSource.observeUser(otherUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          AppUser user = AppUser.fromSnapshot(snapshot.data!);
          return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                  appBar: AppBar(
                      title: StreamBuilder<DocumentSnapshot>(
                          stream: _databaseSource.observeUser(otherUserId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            user = AppUser.fromSnapshot(snapshot.data!);
                            return ChatTopBar(user: user);
                          })),
                  body: Container(
                    decoration: const BoxDecoration(color: kBlueColor),
                    child: Column(children: [
                      Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: _databaseSource.observeMessages(chatId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Container();
                                List<Message> messages = [];
                                for (var element in snapshot.data!.docs) {
                                  messages.add(Message.fromSnapshot(element));
                                }
                                // messages.forEach((element) {
                                //   print(
                                //       "sender = ${element.senderId}, message = ${element.text}, time = ${convertEpochMsToDateTime(element.epochTimeMs)}");
                                // });
                                //messages = generateExactTimeMockMessages(myUserId: myUserId);
                                //messages.sort((a, b) => b.epochTimeMs.compareTo(a.epochTimeMs));

                                if (snapshot.data!.docs.isNotEmpty) {
                                  checkAndUpdateLastMessageSeen(messages.first,
                                      snapshot.data!.docs[0].id, myUserId);
                                }
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    0.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  );
                                }

                                List<bool> showTimeList =
                                    List<bool>.filled(messages.length, false);

                                for (int i = messages.length - 1; i >= 0; i--) {
                                  bool shouldShow = i == (messages.length - 1)
                                      ? true
                                      : shouldShowTime(
                                          messages[i], messages[i + 1]);
                                  showTimeList[i] = shouldShow;
                                }
                                return messages.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        reverse: true,
                                        controller: _scrollController,
                                        itemCount: messages.length,
                                        itemBuilder: (context, index) {
                                          final item = messages[index];
                                          return ListTile(
                                            title: MessageBubble(
                                                epochTimeMs: item.epochTimeMs,
                                                text: item.text,
                                                isSenderMyUser:
                                                    messages[index].senderId ==
                                                        myUserId,
                                                includeTime:
                                                    showTimeList[index]),
                                          );
                                        },
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                            image: AssetImage(
                                                'images/salute_icon.png'),
                                            width: 150,
                                            height: 150,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Text(
                                              "Say Sulute! to ${user.name}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                      fontSize: 18,
                                                      color:
                                                          kColorPrimaryVariant,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      );
                              })),
                      getBottomContainer(context, myUserId),
                    ]),
                  )));
        });
  }

  void sendMessage(String myUserId) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    print("time sent === $timestamp");

    if (messageTextController.text.isEmpty) return;

    Message message = Message(DateTime.now().millisecondsSinceEpoch, false,
        myUserId, messageTextController.text);
    Chat updatedChat = Chat(chatId, message);
    _databaseSource.addMessage(chatId, message);
    _databaseSource.updateChat(updatedChat);
    messageTextController.clear();
  }

  Widget getBottomContainer(BuildContext context, String myUserId) {
    return Container(
      decoration: const BoxDecoration(
        color: kPrimaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextField(
                controller: messageTextController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: kSecondaryColor),
                decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle:
                        TextStyle(color: kSecondaryColor.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.only(left: 12)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                    onPressed: () {
                      sendMessage(myUserId);
                    },
                    icon: Image.asset(
                      'images/send_message_icon.png',
                      width: 30,
                      height: 30,
                      color: const Color(0xAF1F89F8),
                    ))),
          ],
        ),
      ),
    );
  }
}
