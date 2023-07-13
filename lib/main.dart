import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salute/ui/screens/chat_screen.dart';
import 'package:salute/ui/screens/login_screen.dart';
import 'package:salute/ui/screens/main_navigation_screen.dart';
import 'package:salute/ui/screens/matched_screen.dart';
import 'package:salute/ui/screens/register_screen.dart';
import 'package:salute/ui/screens/splash_screen.dart';
import 'package:salute/ui/screens/start_screen.dart';
import 'package:salute/ui/screens/user_details_screen.dart';
import 'package:salute/util/constants.dart';


import 'data/db/entity/app_user.dart';
import 'data/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: kFontFamily,
          indicatorColor: kAccentColor,
          scaffoldBackgroundColor: kPrimaryColor,
          hintColor: kSecondaryColor,
          appBarTheme: AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor: kBackgroundColor,
            shadowColor: kBlueColor,
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 38.0, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ).apply(
            bodyColor: kSecondaryColor,
            displayColor: kSecondaryColor,
          ),
          buttonTheme: ButtonThemeData(
            splashColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 14),
            buttonColor: kAccentColor,
            textTheme: ButtonTextTheme.accent,
            highlightColor: Color.fromRGBO(0, 0, 0, .3),
            focusColor: Color.fromRGBO(0, 0, 0, .3),
          ), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(kBackgroundColorInt, kThemeMaterialColor)).copyWith(secondary: kSecondaryColor),
        ),
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          StartScreen.id: (context) => StartScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegisterScreen.id: (context) => RegisterScreen(),
          MainNavigationScreen.id: (context) => MainNavigationScreen(),
          MatchedScreen.id: (context) => MatchedScreen(
                myProfilePhotoPath: (ModalRoute.of(context)?.settings.arguments
                    as Map)['my_profile_photo_path'],
                myUserId: (ModalRoute.of(context)?.settings.arguments
                    as Map)['my_user_id'],
                otherUserProfilePhotoPath: (ModalRoute.of(context)
                    ?.settings
                    .arguments as Map)['other_user_profile_photo_path'],
                otherUserId: (ModalRoute.of(context)?.settings.arguments
                    as Map)['other_user_id'],
              ),
          ChatScreen.id: (context) => ChatScreen(
                chatId: (ModalRoute.of(context)?.settings.arguments
                    as Map)['chat_id'],
                otherUserId: (ModalRoute.of(context)?.settings.arguments
                    as Map)['other_user_id'],
                myUserId: (ModalRoute.of(context)?.settings.arguments
                    as Map)['user_id'],
              ),
          UserDetailsScreen.id: (context) => UserDetailsScreen(
            user: ModalRoute.of(context)?.settings.arguments as AppUser,
          ),
        },
      ),
    );
  }
}
