import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatelessWidget {
  const CustomDropdownFormField({
    this.onChanged,
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
    this.addPadding = true,
    this.initialValue = '',
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
  final List<String> items;
  final String selectedItem;
  final bool addPadding;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: this.addPadding
          ? EdgeInsets.only(
              left: 30,
              right: 30,
            )
          : null,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
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
            isEmpty: selectedItem == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                value: selectedItem.isNotEmpty ? selectedItem : null,
                isDense: true,
                onChanged: onChanged,
                items: items.map(
                  (String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        softWrap: true,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyText1,
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
