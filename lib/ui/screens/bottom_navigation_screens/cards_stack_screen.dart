//import 'dart:js_interop';

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
import 'package:salute/util/constants.dart';
import 'package:salute/util/utils.dart';

import '../../widgets/drag_cart.dart';

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
  late final AnimationController _animationController;
  List<AppUser> users = [];
  AppUser? otherUser;
  int? otherUserIndex;
  int threshold = 1;

  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
       // _ignoreSwipeIds.removeLast();
        _animationController.reset();

        swipeNotifier.value = Swipe.none;
      }
    });
  }

  Future<AppUser?> loadPerson(String userId) async {
    if (_ignoreSwipeIds.isEmpty) {
      _ignoreSwipeIds = [];
      var swipes = await _databaseSource.getSwipes(userId);
      print("swipes == $swipes");
      for (var i = 0; i < swipes.size; i++) {
        SwipeModel swipe = SwipeModel.fromSnapshot(swipes.docs[i]);
        _ignoreSwipeIds.add(swipe.id);
      }
      _ignoreSwipeIds.add(userId);
    }
    var res = await _databaseSource.getPersonsToMatchWith(1, _ignoreSwipeIds);
    print("res == $res");
    if (res.docs.isNotEmpty) {
      var userToMatchWith = AppUser.fromSnapshot(res.docs.first);
      return userToMatchWith;
    } else {
      return null;
    }
  }

  Future<List<AppUser>> loadPersons(String userId) async {
    if (_ignoreSwipeIds.isEmpty) {
      var swipes = await _databaseSource.getSwipes(userId);
      for (var i = 0; i < swipes.size; i++) {
        SwipeModel swipe = SwipeModel.fromSnapshot(swipes.docs[i]);
        _ignoreSwipeIds.add(swipe.id);
      }

    }
    _ignoreSwipeIds.add(userId);
    var res = await _databaseSource.getPersonsToMatchWith(10, _ignoreSwipeIds);
    if (res.docs.isNotEmpty) {
      for (var doc in res.docs) {
        var userToMatchWith = AppUser.fromSnapshot(doc);
        users.add(userToMatchWith);
      }
    }
    return users;
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
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaY: 0.5, sigmaX: 0.5),
            child: Image.asset(
              'images/shapes_background.png',
              fit: BoxFit.cover,
              color: kBlueColor,
            ),
          ),
          Consumer<UserProvider?>(
            builder: (context, userProvider, child) {
              return FutureBuilder<AppUser?>(
                future: userProvider?.user,
                builder: (context, userSnapshot) {
                  return CustomModalProgressHUD(
                    inAsyncCall: userProvider == null || userProvider.isLoading,
                    offset: null,
                    child: (userSnapshot.hasData)
                        ? FutureBuilder<List<AppUser>>(
                        future: loadPersons(userProvider?.userId ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done &&
                              !snapshot.hasData || users.isEmpty) {
                            return Center(
                              child: Text('No users',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                            );
                          }
                          if (!snapshot.hasData) {
                            return CustomModalProgressHUD(
                              inAsyncCall: true,
                              offset: null,
                              child: Container(),
                            );
                          }
                          if (users.length <= threshold) {
                            return FutureBuilder<List<AppUser>>(
                                future: loadPersons(userProvider?.userId ?? ''),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || users.isEmpty) {
                                    return Center(
                                      child: Text('No users',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium),
                                    );
                                  }
                                  if (users.length <= threshold) {
                                    return FutureBuilder<List<AppUser>>(
                                        future: loadPersons(userProvider?.userId ?? ''),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return CustomModalProgressHUD(
                                              inAsyncCall: true,
                                              offset: null,
                                              child: Container(),
                                            );
                                          }
                                          if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
                                            return Center(
                                              child: Text('No more users',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium),
                                            );
                                          }
                                          users.addAll(snapshot.data ?? []);
                                          return buildUsersStack(userSnapshot, users);
                                        }
                                    );
                                  } else {
                                    return buildUsersStack(userSnapshot, users);
                                  }
                                }
                            );
                          } else {
                            return buildUsersStack(userSnapshot, users);
                          }
                        })
                        : Container(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

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
                  buttonColor: kRedColor,
                  iconSize: 30,
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
                  buttonColor: null,
                  iconColor: kRedColor,
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
  }

}