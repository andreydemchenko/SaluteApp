import 'package:flutter/material.dart';
import 'package:salute/ui/widgets/bordered_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailAndPasswordScreen extends StatelessWidget {
  final Function(String) emailOnChanged;
  final Function(String) passwordOnChanged;

  const EmailAndPasswordScreen(
      {super.key, required this.emailOnChanged, required this.passwordOnChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.myEmailAndPassword,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: 25),
        BorderedTextField(
          labelText: AppLocalizations.of(context)!.email,
          onChanged: emailOnChanged,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 5),
        BorderedTextField(
          labelText: AppLocalizations.of(context)!.password,
          onChanged: passwordOnChanged,
          obscureText: true,
        ),
      ],
    );
  }
}
