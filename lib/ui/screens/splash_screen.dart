import 'package:flutter/material.dart';
import 'package:salute/ui/screens/start_screen.dart';
import 'package:salute/ui/screens/main_navigation_screen.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/util/shared_preferences_utils.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkIfUserExists();
  }

  Future<void> checkIfUserExists() async {
    String? userId = await SharedPreferencesUtil.getUserId();
    Navigator.pop(context);
    if (userId != null) {
      Navigator.pushNamed(context, MainNavigationScreen.id);
    } else {
      Future.delayed(Duration.zero, () {
      Navigator.pushNamed(context, StartScreen.id);
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: kDefaultPadding,
          child: Container(),
        ),
      ),
    );
  }
}
