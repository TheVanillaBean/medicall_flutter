import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDatePickerFormField extends StatelessWidget {
  const CustomDatePickerFormField({
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: TextFormField(
        inputFormatters: inputFormatters,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(
          hintText: 'MM/DD/YYYY',
          hintStyle: Theme.of(context).textTheme.caption,
          labelText: 'Date of Birth',
          labelStyle: Theme.of(context).textTheme.bodyText1,
          errorText: errorText,
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
        keyboardType: TextInputType.number,
        onChanged: (val) => onChanged(
          convertToDate(val),
        ),
        controller: controller,
      ),
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
}
