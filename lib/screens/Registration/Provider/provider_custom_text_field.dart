import 'package:flutter/material.dart';

class ProviderCustomTextField extends StatelessWidget {
  const ProviderCustomTextField({
    this.onSaved,
    this.icon,
    this.labelText,
    this.hint,
    this.obscure = false,
    this.validator,
    this.controller,
  });
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final String labelText;
  final String hint;
  final bool obscure;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: TextFormField(
        autofocus: true,
        //obscureText: false,
        style: TextStyle(fontSize: 18, color: Colors.black87),
        decoration: InputDecoration(
          icon: IconTheme(
              data: IconThemeData(color: Colors.black54), child: icon),
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 16, color: Colors.black54),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 16, color: Colors.black26),
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
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
