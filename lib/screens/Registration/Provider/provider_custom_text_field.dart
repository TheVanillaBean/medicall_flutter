import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProviderCustomTextField extends StatelessWidget {
  const ProviderCustomTextField({
    this.onChanged,
    this.icon,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled,
    this.errorText,
    this.obscureText,
    this.inputFormatters,
    this.onTapped,
  });
  final ValueChanged<String> onChanged;
  final Icon icon;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String errorText;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final GestureTapCallback onTapped;

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
        obscureText: obscureText ?? false,
        controller: controller,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        autofocus: true,
        style: Theme.of(context).textTheme.bodyText1,
        onTap: onTapped,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          hintText: hint,
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
        keyboardType: keyboardType,
//        validator: (input) {
//          if (input.isEmpty) {
//            return '$labelText is required';
//          }
//          return null;
//        },
      ),
    );
  }
}
