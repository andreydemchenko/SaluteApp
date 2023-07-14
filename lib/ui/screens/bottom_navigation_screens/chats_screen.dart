import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/data/model/chat_with_user.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/chat_screen.dart';
import 'package:salute/ui/widgets/chats_list.dart';
import 'package:salute/ui/widgets/custom_modal_progress_hud.dart';
import 'package:salute/util/constants.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _searchText = "";

  void chatWithUserPressed(ChatWithUser chatWithUser) async {
    AppUser? user =
        await Provider.of<UserProvider>(context, listen: false).user;
    Navigator.pushNamed(context, ChatScreen.id, arguments: {
      "chat_id": chatWithUser.chat.id,
      "user_id": user?.id,
      "other_user_id": chatWithUser.user.id
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 80.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Search by user name",
                    labelStyle: TextStyle(color: kBackgroundColor),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Consumer<UserProvider?>(
                  builder: (context, userProvider, child) {
                    return FutureBuilder<AppUser?>(
                      future: userProvider?.user,
                      builder: (context, userSnapshot) {
                        final user = userSnapshot.data;
                        final userLoading = userProvider?.isLoading ?? true;

                        return CustomModalProgressHUD(
                          inAsyncCall: user == null || userLoading,
                          offset: null,
                          child: (userSnapshot.hasData && user != null)
                              ? StreamBuilder<List<ChatWithUser>>(
                            stream: userProvider?.getChatsWithUserStream(user.id),
                            builder: (context, chatWithUsersSnapshot) {
                              if (chatWithUsersSnapshot.data == null &&
                                  chatWithUsersSnapshot.connectionState !=
                                      ConnectionState.active) {
                                return CustomModalProgressHUD(
                                  inAsyncCall: true,
                                  offset: null,
                                  child: Container(),
                                );
                              } else {
                                List<ChatWithUser> chats =
                                    chatWithUsersSnapshot.data ?? [];
                                chats = chats
                                    .where((chatWithUser) => chatWithUser
                                    .user.name
                                    .toLowerCase()
                                    .contains(
                                    _searchText.toLowerCase()))
                                    .toList();
                                return chats.isEmpty ?? true
                                    ? Center(
                                  child: Container(
                                    child: Text(
                                      'No matches',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ),
                                )
                                    : ChatsList(
                                  chatWithUserList: chats,
                                  onChatWithUserTap:
                                  chatWithUserPressed,
                                  myUserId: user.id,
                                );
                              }
                            },
                          )
                              : Container(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
