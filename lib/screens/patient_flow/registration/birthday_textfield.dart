import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BirthdayTextField extends StatelessWidget {
  const BirthdayTextField({
    this.icon,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled,
    this.errorText,
    this.obscureText,
    this.initialDate,
    this.inputFormatters,
    this.onChanged,
    this.fillColor,
    this.filled,
  });
  final Icon icon;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final List<TextInputFormatter> inputFormatters;
  final String errorText;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;
  final Color fillColor;
  final bool filled;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        fillColor: fillColor,
        filled: filled,
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.caption,
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyText1,
        errorText: errorText,
        prefixIcon: icon,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        border: InputBorder.none,
        enabled: enabled,
      ),
      initialValue: initialDateFormatted,
      keyboardType: keyboardType,
      onChanged: (val) => onChanged(
        convertToDate(val),
      ),
      controller: controller,
    );
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  String get initialDateFormatted {
    if (this.initialDate == null) {
      return "";
    }
    final f = new DateFormat('MM/dd/yyyy');
    return "${f.format(this.initialDate)}";
  }
}
