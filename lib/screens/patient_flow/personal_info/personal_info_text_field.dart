import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoTextField extends StatefulWidget {
  const PersonalInfoTextField({
    this.onChanged,
    this.inputFormatters,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled,
    this.errorText,
    this.obscureText,
    this.initialText = '',
  });
  final ValueChanged<String> onChanged;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String errorText;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final String initialText;

  @override
  _PersonalInfoTextFieldState createState() => _PersonalInfoTextFieldState();
}

class _PersonalInfoTextFieldState extends State<PersonalInfoTextField> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();
    if (widget.initialText != null) {
      controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        autocorrect: false,
        obscureText: widget.obscureText ?? false,
        controller: controller,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        autofocus: true,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: widget.errorText,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          hintText: widget.hint,
          hintStyle: Theme.of(context).textTheme.caption,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black26,
              width: 0.5,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 0.5,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 0.5,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 0.5,
            ),
          ),
        ),
        keyboardType: widget.keyboardType,
      ),
    );
  }
}
