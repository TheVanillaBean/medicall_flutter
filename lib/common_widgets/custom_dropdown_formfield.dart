import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatelessWidget {
  const CustomDropdownFormField({
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
    this.items,
    this.selectedItem,
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
  final List<String> items;
  final String selectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              icon: IconTheme(
                  data: IconThemeData(color: Colors.black54), child: icon),
              labelText: labelText,
              labelStyle: TextStyle(fontSize: 16, color: Colors.black54),
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
            isEmpty: selectedItem == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: selectedItem.isNotEmpty ? selectedItem : null,
                isDense: true,
                onChanged: onChanged,
                items: items.map(
                  (String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
