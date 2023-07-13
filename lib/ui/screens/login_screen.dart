import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salute/data/db/remote/response.dart';
import 'package:salute/data/provider/user_provider.dart';
import 'package:salute/ui/screens/main_navigation_screen.dart';
import 'package:salute/ui/widgets/bordered_text_field.dart';
import 'package:salute/ui/widgets/custom_modal_progress_hud.dart';
import 'package:salute/ui/widgets/rounded_button.dart';
import 'package:salute/util/constants.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _inputEmail = '';
  String _inputPassword = '';
  bool _isLoading = false;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of(context, listen: false);
  }

  void loginPressed() async {
    setState(() {
      _isLoading = true;
    });
    await _userProvider
        .loginUser(_inputEmail, _inputPassword, _scaffoldKey)
        .then((response) {
      if (response is Success<UserCredential>) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(MainNavigationScreen.id, (route) => false);
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: CustomModalProgressHUD(
          inAsyncCall: _isLoading,
          offset: null,
          child: Padding(
            padding: kDefaultPadding,
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login to your account',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: 40),
                  BorderedTextField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _inputEmail = value,
                  ),
                  SizedBox(height: 5),
                  BorderedTextField(
                    labelText: 'Password',
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    onChanged: (value) => _inputPassword = value,
                  ),
                  Expanded(child: Container()),
                  RoundedButton(text: 'LOGIN', onPressed: () { loginPressed(); })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
