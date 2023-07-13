import 'package:flutter/material.dart';
import 'package:salute/ui/widgets/bordered_text_field.dart';
import 'package:salute/util/constants.dart';

class InputDialog extends StatefulWidget {
  final String labelText;
  final Function(String) onSavePressed;
  final String startInputText;

  @override
  _InputDialogState createState() => _InputDialogState();

  const InputDialog(
      {super.key, required this.labelText,
        required this.onSavePressed,
        this.startInputText = ''});
}

class _InputDialogState extends State<InputDialog> {
  String inputText = '';
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.startInputText;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimaryColor,
      contentPadding: EdgeInsets.all(16.0),
      content: SingleChildScrollView(  // Wrap your content in a SingleChildScrollView
        child: BorderedTextField(
          textCapitalization: TextCapitalization.sentences,
          labelText: widget.labelText,
          autoFocus: true,
          keyboardType: TextInputType.text,
          onChanged: (value) => {inputText = value},
          textController: textController,
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: kAccentColor,
          ),
          child: Text(
            'CANCEL',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: kBackgroundColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: kColorPrimaryVariant,
          ),
          child: Text(
            'SAVE',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: kPrimaryColor),
          ),
          onPressed: () {
            widget.onSavePressed(inputText);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
