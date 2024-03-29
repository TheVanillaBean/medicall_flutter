import 'package:flutter/material.dart';

class PrescriptionDetailsTextField extends StatelessWidget {
  const PrescriptionDetailsTextField({
    this.onChanged,
    this.labelText,
    this.initialValue,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled = true,
    this.errorText,
    this.maxLines,
    this.focusNode,
  });
  final ValueChanged<String> onChanged;
  final String labelText;
  final String initialValue;
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
        textCapitalization: TextCapitalization.sentences,
        initialValue: this.initialValue,
        focusNode: focusNode,
        maxLines: maxLines,
        autocorrect: false,
        controller: controller,
        onChanged: onChanged,
        autofocus: false,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        enabled: this.enabled,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          isDense: true,
          labelText: labelText,
          errorText: errorText,
          labelStyle: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          hintText: this.initialValue,
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
