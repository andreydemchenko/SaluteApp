//import 'dart:js_interop';

import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salute/data/db/entity/app_user.dart';
import 'package:salute/data/db/entity/chat.dart';
import 'package:salute/data/db/entity/match.dart';
import 'package:salute/data/db/entity/swipe_model.dart';
import 'package:salute/data/db/remote/firebase_database_source.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/matched_screen.dart';
import 'package:salute/ui/widgets/custom_modal_progress_hud.dart';
import 'package:salute/ui/widgets/rounded_icon_button.dart';
import 'package:salute/ui/widgets/swipe_card.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/util/utils.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CardsStackScreen extends StatefulWidget {
  const CardsStackScreen({Key? key}) : super(key: key);
  @override
  _CardsStackScreenState createState() => _CardsStackScreenState();
}

class _CardsStackScreenState extends State<CardsStackScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<String> _ignoreSwipeIds = [];
  final StreamController<List<AppUser>> _userStreamController =
      StreamController<List<AppUser>>();
  List<AppUser> users = [];
  AppUser? otherUser;
  int? otherUserIndex;

  Stream<List<AppUser>> usersStream(String userId) async* {
    if (_ignoreSwipeIds.isEmpty) {
      var swipes = await _databaseSource.getSwipes(userId);
      for (var i = 0; i < swipes.size; i++) {
        SwipeModel swipe = SwipeModel.fromSnapshot(swipes.docs[i]);
        _ignoreSwipeIds.add(swipe.id);
      }
    }
    _ignoreSwipeIds.add(userId);

    await for (var users in _databaseSource
        .getPersonsToMatchWith(10, _ignoreSwipeIds)
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => AppUser.fromSnapshot(doc))
          .toList();
    })) {
      yield users;
    }
  }

  void personSwiped(AppUser myUser, AppUser otherUser, bool isLiked) async {
    _databaseSource.addSwipedUser(myUser.id, SwipeModel(otherUser.id, isLiked));
    _ignoreSwipeIds.add(otherUser.id);

    if (isLiked == true) {
      if (await isMatch(myUser, otherUser) == true) {
        _databaseSource.addMatch(myUser.id, Match(otherUser.id));
        _databaseSource.addMatch(otherUser.id, Match(myUser.id));
        String chatId = compareAndCombineIds(myUser.id, otherUser.id);
        _databaseSource.addChat(Chat(chatId, null));

        Navigator.pushNamed(context, MatchedScreen.id, arguments: {
          "my_user_id": myUser.id,
          "my_profile_photo_path":
              myUser.profilePhotoPaths[myUser.profilePhotoIndex],
          "other_user_profile_photo_path":
              otherUser.profilePhotoPaths[otherUser.profilePhotoIndex],
          "other_user_id": otherUser.id
        });
      }
    }
    setState(() {
      users.remove(otherUser);
    });
  }

  Future<bool> isMatch(AppUser myUser, AppUser otherUser) async {
    DocumentSnapshot swipeSnapshot =
        await _databaseSource.getSwipe(otherUser.id, myUser.id);
    if (swipeSnapshot.exists) {
      SwipeModel swipe = SwipeModel.fromSnapshot(swipeSnapshot);

      if (swipe.liked == true) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Consumer<UserProvider?>(
      builder: (context, userProvider, child) {
        return FutureBuilder<AppUser?>(
          future: userProvider?.user,
          builder: (context, userSnapshot) {
            return CustomModalProgressHUD(
              inAsyncCall: userProvider == null || userProvider.isLoading,
              offset: null,
              child: (userSnapshot.hasData)
                  ? StreamBuilder<List<AppUser>>(
                      stream: usersStream(userProvider?.userId ?? ''),
                      builder: (context, snapshot) {
                        return CustomModalProgressHUD(
                            inAsyncCall: snapshot.connectionState ==
                                ConnectionState.waiting,
                            offset: null,
                            child: (snapshot.hasData)
                                ? Stack(clipBehavior: Clip.none, children: [
                                    SwipeCards(
                                      matchEngine: MatchEngine(
                                          swipeItems:
                                              snapshot.data!.map((user) {
                                        return SwipeItem(
                                            content: SwipeCard(person: user),
                                            likeAction: () {
                                              log("like ${user.name}");
                                              personSwiped(userSnapshot.data!,
                                                  user, true);
                                            },
                                            nopeAction: () {
                                              log("dislike ${user.name}");
                                              personSwiped(userSnapshot.data!,
                                                  user, false);
                                            });
                                      }).toList()),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        otherUser = snapshot.data![index];
                                        return Center(
                                            child: SwipeCard(
                                                person: snapshot.data![index]));
                                      },
                                      onStackFinished: () {
                                        Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .noMoreUsers,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium));
                                      },
                                      upSwipeAllowed: false,
                                    ),
                                    snapshot.data!.isNotEmpty ?
                                    Positioned(
                                      bottom: 10,
                                      left: 20,
                                      right: 20,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RoundedIconButton(
                                              onPressed: () {
                                                if (otherUser != null) {
                                                  personSwiped(
                                                      userSnapshot.data!,
                                                      otherUser!,
                                                      false);
                                                }
                                              },
                                              iconData: Icons.clear,
                                              buttonColor: kPrimaryColor,
                                              iconSize: 34,
                                              iconColor: kSecondaryColor,
                                            ),
                                            SizedBox(width: 18),
                                            RoundedIconButton(
                                              onPressed: () {
                                                if (otherUser != null) {
                                                  personSwiped(
                                                      userSnapshot.data!,
                                                      otherUser!,
                                                      true);
                                                }
                                              },
                                              iconData: Icons.favorite,
                                              iconSize: 34,
                                              buttonColor: kPrimaryColor,
                                              iconColor: kSecondaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ) : Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .noMoreUsers,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium))
                                  ])
                                : Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .noMoreUsers,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium)));
                      })
                  : Container(),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _userStreamController.close();
    super.dispose();
  }
/*
  Widget buildUsersStack(AsyncSnapshot<AppUser?> userSnapshot, List<AppUser> users) {
    double cardWidth = MediaQuery.of(context).size.width * 0.85;
    double cardHeight = MediaQuery.of(context).size.height * 0.725;
    AppUser? otherUser;
    int? otherUserIndex;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ValueListenableBuilder(
            valueListenable: swipeNotifier,
            builder: (context, swipe, _) => Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children:
              List.generate(users.length, (index) {
                otherUser = users[index];
                otherUserIndex = index;
                if (index == users.length - 1) {
                  return PositionedTransition(
                    rect: RelativeRectTween(
                      begin: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              0, 0, cardWidth, cardHeight),
                          Size(cardWidth, cardHeight)),
                      end: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              swipe != Swipe.none
                                  ? swipe == Swipe.left
                                  ? -300
                                  : 300
                                  : 0,
                              0,
                              cardWidth,
                              cardHeight),
                          Size(cardWidth, cardHeight)),
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    )),
                    child: RotationTransition(
                      turns: Tween<double>(
                          begin: 0,
                          end: swipe != Swipe.none
                              ? swipe == Swipe.left
                              ? -0.1 * 0.3
                              : 0.1 * 0.3
                              : 0.0)
                          .animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0, 0.4,
                              curve: Curves.easeInOut),
                        ),
                      ),
                      child: DragWidget(
                        myUser: userSnapshot.data!,
                        profile: otherUser!,
                        index: index,
                        swipeNotifier: swipeNotifier,
                        onSwipeCompleted: personSwiped,
                      ),
                    ),
                  );
                } else {
                  return DragWidget(
                    myUser: userSnapshot.data!,
                    profile: otherUser!,
                    index: index,
                    swipeNotifier: swipeNotifier,
                    isLastCard: true,
                    onSwipeCompleted: personSwiped,
                  );
                }
              }),
            ),
          ),
        ),

        Positioned(
          bottom: 10,
          left: 20,
          right: 20,
          child: Padding(
            padding:
            const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                RoundedIconButton(
                  onPressed: () {
                    if (otherUser != null) {
                      personSwiped(
                          userSnapshot.data!, // myUser
                          otherUser!, // otherUser
                          false);
                      swipeNotifier.value = Swipe.left;
                      _animationController.forward();
                    }
                    // setState(() {
                    //   users.removeAt(otherUserIndex!);
                    // });
                  },
                  iconData: Icons.clear,
                  buttonColor: kPrimaryColor,
                  iconSize: 30,
                  iconColor: kSecondaryColor,
                ),
                Spacer(),
                RoundedIconButton(
                  onPressed: () {
                    if (otherUser != null) {
                      personSwiped(
                          userSnapshot.data!,
                          otherUser!,
                          true);
                      swipeNotifier.value = Swipe.right;
                      _animationController.forward();
                      // setState(() {
                      //   users.removeAt(otherUserIndex!);
                      // });
                    } // ked
                  },
                  iconData: Icons.favorite,
                  iconSize: 30,
                  buttonColor: kPrimaryColor,
                  iconColor: kSecondaryColor,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: DragTarget<int>(
            builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
                ) {
              return IgnorePointer(
                child: Container(
                  height: 700.0,
                  width: 80.0,
                  color: Colors.transparent,
                ),
              );
            },
            onAccept: (int index) {
              if (otherUser != null) {
                personSwiped(
                    userSnapshot.data!,
                    otherUser!,
                    false);
              }
              // setState(() {
              //   users.removeAt(index);
              // });
            },
          ),
        ),
        Positioned(
          right: 0,
          child: DragTarget<int>(
            builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
                ) {
              return IgnorePointer(
                child: Container(
                  height: 700.0,
                  width: 80.0,
                  color: Colors.transparent,
                ),
              );
            },
            onAccept: (int index) {
              if (otherUser != null) {
                personSwiped(
                    userSnapshot.data!,
                    otherUser!,
                    true);
              }
              // setState(() {
              //   users.removeAt(index);
              // });
            },
          ),
        ),
      ],
    );
  }*/
}
