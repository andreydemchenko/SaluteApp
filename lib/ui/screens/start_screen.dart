import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/ui/widgets/app_image_with_text.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/ui/widgets/rounded_outlined_button.dart';
import 'package:salute/ui/screens/login_screen.dart';
import 'package:salute/ui/screens/register_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StartScreen extends StatelessWidget {
  static const String id = 'start_screen';

  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kSecondaryColor,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaY: 2, sigmaX: 1),
              child: Image.asset(
                'images/shapes_background.png',
                fit: BoxFit.cover,
                color: kAccentColor.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: kDefaultPadding,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Container()),
                    SizedBox(
                      width: 150.0,
                      height: 150.0,
                      child: Image.asset('images/blue_salute_logo.png'),
                    ),
                    //Expanded(child: Container()),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Salute!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: kPrimaryColor),
                      ),
                    ),
                    SizedBox(height: 60),
                    RoundedButton(
                      buttonColor: kPrimaryColor,
                      text: AppLocalizations.of(context)!.createAccount,
                      onPressed: () {
                        Future.delayed(Duration.zero, () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, RegisterScreen.id);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    RoundedButton(
                      buttonColor: kPrimaryColor,
                      text: AppLocalizations.of(context)!.login,
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
          ],
        ),
      ),
    );
  }
}
