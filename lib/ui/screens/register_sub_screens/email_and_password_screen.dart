import 'package:flutter/material.dart';
import 'package:salute/ui/widgets/bordered_text_field.dart';

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
          'My Email and',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Text(
          'Password is',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: 25),
        BorderedTextField(
          labelText: 'Email',
          onChanged: emailOnChanged,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 5),
        BorderedTextField(
          labelText: 'Password',
          onChanged: passwordOnChanged,
          obscureText: true,
        ),
      ],
    );
  }
}
