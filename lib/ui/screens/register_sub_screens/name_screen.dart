import 'package:flutter/material.dart';
import 'package:salute/ui/widgets/bordered_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NameScreen extends StatelessWidget {
  final Function(String) onChanged;

  const NameScreen({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              AppLocalizations.of(context)!.myFirstNameIs,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        SizedBox(height: 25),
        Expanded(
          child: BorderedTextField(
            labelText: AppLocalizations.of(context)!.name,
            onChanged: onChanged,
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }
}
