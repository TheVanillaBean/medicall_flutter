import 'package:flutter/material.dart';

class DocumentationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String initialValue;
  final int maxLines;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const DocumentationTextField({
    this.controller,
    this.labelText,
    this.initialValue,
    this.maxLines,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        focusNode: focusNode,
        autocorrect: false,
        onChanged: onChanged,
        autofocus: true,
        maxLines: maxLines,
        style: TextStyle(
          height: 1.5,
          fontFamily: 'Roboto Regular',
          fontSize: 14.0,
          color: Colors.black54,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          isDense: true,
          labelText: labelText,
          labelStyle: TextStyle(
            fontFamily: 'Roboto Thin',
            fontSize: 16.0,
            color: Colors.black87,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Roboto Regular',
            fontSize: 14.0,
            color: Colors.black26,
          ),
        ),
      ),
    );
  }
}
