import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

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
    this.onChanged,
  });
  final Icon icon;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
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
      child: DateTimeField(
        format: DateFormat('MM/dd/yyyy'),
        decoration: InputDecoration(
          icon: IconTheme(
              data: IconThemeData(color: Colors.black54), child: icon),
          labelText: labelText,
          errorText: errorText,
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
        onChanged: onChanged,
        onShowPicker: (context, currentValue) async {
          FocusScope.of(context).requestFocus(new FocusNode());
          final DateTime currentDate = DateTime.now();
          return await showDatePicker(
            context: context,
            firstDate: DateTime(1920),
            initialDate: initialDate,
            lastDate: DateTime(
                currentDate.year - 18, currentDate.month, currentDate.day),
          );
        },
      ),
    );
  }
}
