import 'package:flutter/material.dart';

class PrescriptionDetailsTextField extends StatelessWidget {
  const PrescriptionDetailsTextField({
    this.onChanged,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled,
    this.errorText,
    this.maxLines,
    this.focusNode,
  });
  final ValueChanged<String> onChanged;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String errorText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final int maxLines;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 0,
        right: 0,
      ),
      child: TextFormField(
        focusNode: focusNode,
        maxLines: maxLines,
        autocorrect: false,
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          isDense: true,
          labelText: labelText,
          errorText: errorText,
          labelStyle: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 16, color: Colors.black26),
          border: UnderlineInputBorder(),
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
        validator: (input) {
          if (input.isEmpty) {
            return '$labelText is required';
          }
          return null;
        },
      ),
    );
  }
}
