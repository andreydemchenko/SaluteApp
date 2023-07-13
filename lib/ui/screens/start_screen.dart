import 'package:flutter/material.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/ui/widgets/app_image_with_text.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/ui/widgets/rounded_outlined_button.dart';
import 'package:salute/ui/screens/login_screen.dart';
import 'package:salute/ui/screens/register_screen.dart';

class StartScreen extends StatelessWidget {
  static const String id = 'start_screen';

  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: kDefaultPadding,
          child: Container(
            margin: EdgeInsets.only(bottom: 40, top: 120),
            child: Column(
              children: [
                AppIconTitle(),
                Expanded(child: Container()),
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Lorel ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Nulla in orci justo. Curabitur ac gravida quam.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                RoundedButton(
                  text: 'CREATE ACCOUNT',
                  onPressed: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RegisterScreen.id);
                    });
                  },
                ),
                SizedBox(height: 20),
                RoundedOutlinedButton(
                  text: 'LOGIN',
                  onPressed: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}