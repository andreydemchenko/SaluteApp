import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:salute/data/db/remote/response.dart';
import 'package:salute/data/model/user_registration.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/register_sub_screens/add_photos_screen.dart';
import 'package:salute/ui/screens/register_sub_screens/age_screen.dart';
import 'package:salute/ui/screens/register_sub_screens/email_and_password_screen.dart';
import 'package:salute/ui/screens/register_sub_screens/gender_selection_screen.dart';
import 'package:salute/ui/screens/register_sub_screens/name_screen.dart';
import 'package:salute/ui/screens/main_navigation_screen.dart';
import 'package:salute/ui/screens/register_sub_screens/verify_email_screen.dart';
import 'package:salute/ui/widgets/custom_modal_progress_hud.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/util/constants.dart';
import 'package:salute/util/utils.dart';
import 'package:salute/ui/screens/start_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = 'register_screen';

  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final UserRegistration _userRegistration = UserRegistration();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _endScreenIndex = 4;
  int _currentScreenIndex = 0;
  bool _isLoading = false;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  void registerUser() async {
    setState(() {
      _isLoading = true;
    });

    await _userProvider
        .registerUser(_userRegistration, _scaffoldKey)
        .then((response) {
      if (response is Success) {
        Navigator.pop(context);
        Navigator.pushNamed(context, MainNavigationScreen.id);
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  void sendEmailLink() async {
    setState(() {
      _isLoading = true;
    });

    Response<dynamic> response =
        await _userProvider.sendVerificationLink(_userRegistration.email);

    if (response is Success<UserCredential>) {
      setState(() {
        _currentScreenIndex++;
      });
      // Navigator.pop(context);
      // Navigator.pushNamed(context, MainNavigationScreen.id);
    } else if (response is Error) {
      //showSnackBar(errorScaffoldKey, response.message);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void goBackPressed() {
    if (_currentScreenIndex == 0) {
      Navigator.pop(context);
      Navigator.pushNamed(context, StartScreen.id);
    } else {
      setState(() {
        _currentScreenIndex--;
      });
    }
  }

  Widget getSubScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return NameScreen(
            onChanged: (value) => {_userRegistration.name = value});
      case 1:
        return AgeScreen(onChanged: (value) => {_userRegistration.age = value});
      case 2:
        return AddPhotosScreen(
            onPhotosChanged: (value) =>
                {_userRegistration.localProfilePhotoPaths = value});
      case 3:
        return GenderSelectionScreen(
            onChanged: (value) => {_userRegistration.gender = value});
      case 4:
        return EmailAndPasswordScreen(
            emailOnChanged: (value) => {_userRegistration.email = value},
            passwordOnChanged: (value) => {_userRegistration.password = value});
      // case 5:
      //   return VerifyEmailScreen(email: _userRegistration.email);
      default:
        return Container();
    }
  }

  bool canContinueToNextSubScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return (_userRegistration.name.length >= 2);
      case 1:
        return (_userRegistration.age >= 13 && _userRegistration.age <= 120);
      case 2:
        return _userRegistration.localProfilePhotoPaths
            .any((path) => path.isNotEmpty);
      case 3:
        return _userRegistration.gender != null;
      case 4:
        return validateFields(
            _userRegistration.email, _userRegistration.password);
      // case 5:
      //   return _userProvider.isEmailVerified;
      default:
        return false;
    }
  }

  bool validateFields(String email, String password) {
    if (email.isEmpty) {
      return false;
    }

    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    if (password.isEmpty) {
      return false;
    }

    if (password.length < 6) {
      return false;
    }

    return true;
  }

  String getInvalidRegistrationMessage() {
    switch (_currentScreenIndex) {
      case 0:
        return AppLocalizations.of(context)!.nameTooShort;
      case 1:
        return AppLocalizations.of(context)!.invalidAge;
      case 2:
        return AppLocalizations.of(context)!.invalidPhoto;
      case 3:
        return AppLocalizations.of(context)!.selectGender;
      case 4:
        return AppLocalizations.of(context)!.invalidInput;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.register)),
        body: CustomModalProgressHUD(
            inAsyncCall: _isLoading,
            offset: null,
            child: Stack(fit: StackFit.expand, children: <Widget>[
              Image.asset(
                  'images/simple_background.png',
                  fit: BoxFit.cover,
                ),
              Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      LinearPercentIndicator(
                          lineHeight: 5,
                          percent: (_currentScreenIndex / _endScreenIndex),
                          progressColor: kAccentColor,
                          padding: EdgeInsets.zero),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            padding: kDefaultPadding.copyWith(
                                left: kDefaultPadding.left / 2.0,
                                right: 0.0,
                                bottom: 4.0,
                                top: 4.0),
                            child: IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(
                                _currentScreenIndex == 0
                                    ? Icons.clear
                                    : Icons.arrow_back,
                                color: kSecondaryColor,
                                size: 42.0,
                              ),
                              onPressed: () {
                                goBackPressed();
                              },
                            )),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Container(
                            width: double.infinity,
                            padding:
                                kDefaultPadding.copyWith(top: 0, bottom: 0),
                            child: getSubScreen()),
                      ),
                      Container(
                        padding: kDefaultPadding,
                        child: _currentScreenIndex == (_endScreenIndex)
                            ? RoundedButton(
                                text:
                                    AppLocalizations.of(context)!.registerUpper,
                                onPressed: _isLoading == false
                                    ? () => registerUser()
                                    : () {})
                            : RoundedButton(
                                text: AppLocalizations.of(context)!.continueLbl,
                                onPressed: () {
                                  if (canContinueToNextSubScreen()) {
                                    // if (_currentScreenIndex ==
                                    //         _endScreenIndex - 1 &&
                                    //     _isLoading == false) {
                                    //   sendEmailLink();
                                    //   //_userProvider.startCheckingEmailVerified(_userRegistration, _scaffoldKey);
                                    // } else {
                                      setState(() {
                                        _currentScreenIndex++;
                                      });
                                    //}
                                  } else {
                                    showSnackBar(_scaffoldKey,
                                        getInvalidRegistrationMessage());
                                  }
                                },
                              ),
                      ),
                    ],
                  )),
            ])),
      ),
    );
  }
}
