import 'package:flutter/material.dart';
import 'package:salute/data/model/main_navigation_item.dart';
import 'package:salute/ui/screens/bottom_navigation_screens/profile_screen.dart';
import 'package:salute/util/constants.dart';
import '../../data/db/entity/app_user.dart';
import '../widgets/swipe_card.dart';
import 'bottom_navigation_screens/chats_screen.dart';
import 'bottom_navigation_screens/cards_stack_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String id = 'bottom_navigation_screen';

  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {

  final List<MainNavigationItem> navigationItems = [
    MainNavigationItem(
      screen: CardsStackScreen(),
      // screen: SwipeCard(person: AppUser(id: "id", name: "jonson", age: 18, profilePhotoPaths: [
      //   "https://firebasestorage.googleapis.com/v0/b/tinderapp-46361.appspot.com/o/user_photos%2FR1QTRtnMPFNjrGm4WdYZUiUpokY2%2Fphoto_0?alt=media&token=e03325e0-daa3-4d7e-8ac8-f8b9471ef5fc",
      //   "https://firebasestorage.googleapis.com/v0/b/tinderapp-46361.appspot.com/o/user_photos%2FR1QTRtnMPFNjrGm4WdYZUiUpokY2%2Fphoto_1?alt=media&token=f150d7b7-1c71-4000-b617-6264850e82c7",
      //    "https://firebasestorage.googleapis.com/v0/b/tinderapp-46361.appspot.com/o/user_photos%2FR1QTRtnMPFNjrGm4WdYZUiUpokY2%2Fphoto_2?alt=media&token=f407bfb5-c4ca-4cea-bfdc-4dad495486dc"],
      //     gender: Gender.male)),
      imagePath: 'images/cards_icon.png',
    ),
    MainNavigationItem(
      title: 'Messages',
      screen: ChatsScreen(),
      imagePath: 'images/chats_icon.png',
    ),
    MainNavigationItem(
      title: 'My profile',
      screen: ProfileScreen(),
      imagePath: 'images/profile_icon.png',
    ),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            if (navigationItems[_currentIndex].title != null)
              Container(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    navigationItems[_currentIndex].title!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kBackgroundColor
                    ),
                  ),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: navigationItems.map((item) => item.screen).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Color(0xFFF8F8F8),
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                        _currentIndex == 0 ? 'images/cards_selected_icon.png' : 'images/cards_unselected_icon.png',
                        width: 30,
                        height: 30
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      navigationItems[1].imagePath,
                      width: 30,
                      height: 30,
                      color: _currentIndex == 1 ? kSecondaryColor : kAccentColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      navigationItems[2].imagePath,
                      width: 30,
                      height: 30,
                      color: _currentIndex == 2 ? kSecondaryColor : kAccentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
