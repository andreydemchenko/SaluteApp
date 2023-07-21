import 'package:flutter/material.dart';
import 'package:salute/data/model/chat_with_user.dart';
import 'package:salute/data/model/chats_observer.dart';
import 'package:salute/ui/widgets/chat_list_tile.dart';

class ChatsList extends StatefulWidget {
  final List<ChatWithUser> chatWithUserList;
  final Function(ChatWithUser) onChatWithUserTap;
  final String myUserId;

  const ChatsList(
      {super.key, required this.chatWithUserList,
      required this.onChatWithUserTap,
      required this.myUserId});

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  late ChatsObserver _chatsObserver;
  bool isChatUpdated = false;

  @override
  void initState() {
    super.initState();
    _chatsObserver = ChatsObserver(widget.chatWithUserList);
    _chatsObserver.startObservers(chatUpdated);
  }

  @override
  @mustCallSuper
  @protected
  void dispose() {
    _chatsObserver.removeObservers();
    super.dispose();
  }

  void chatUpdated() {
    setState(() {
      isChatUpdated = true;
    });
  }

  bool changeMessageSeen(int index) {
    return widget.chatWithUserList[index].chat.lastMessage?.seen == false &&
        widget.chatWithUserList[index].chat.lastMessage?.senderId !=
            widget.myUserId;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: Colors.grey),
      itemCount: widget.chatWithUserList.length,
      itemBuilder: (BuildContext _, int index) => ChatListTile(
        chatWithUser: widget.chatWithUserList[index],
        onTap: () => {
          setState(() {
          if (widget.chatWithUserList[index].chat.lastMessage != null &&
              changeMessageSeen(index)) {
            widget.chatWithUserList[index].chat.lastMessage?.seen = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              chatUpdated();
            });
          }

            widget.onChatWithUserTap(widget.chatWithUserList[index]);
          })
        },
        onLongPress: () {},
        myUserId: widget.myUserId,
      ),
    );
  }
}