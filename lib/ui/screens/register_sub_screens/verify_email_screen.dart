import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const String id = 'verify_email_screen';
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(
        children: [
          Text(
            AppLocalizations.of(context)!.sentVerificationLink,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            AppLocalizations.of(context)!.checkEmailToConfirm,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    ]);
  }
}
