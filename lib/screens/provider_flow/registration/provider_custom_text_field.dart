import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProviderCustomTextField extends StatefulWidget {
  const ProviderCustomTextField({
    this.onChanged,
    this.icon,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.enabled,
    this.errorText,
    this.obscureText,
    this.inputFormatters,
    this.onTapped,
    this.initialText = '',
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
  final List<TextInputFormatter> inputFormatters;
  final GestureTapCallback onTapped;
  final String initialText;

  @override
  _ProviderCustomTextFieldState createState() =>
      _ProviderCustomTextFieldState();
}

class _ProviderCustomTextFieldState extends State<ProviderCustomTextField> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();
    if (widget.initialText != null) {
      controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: TextFormField(
        enableInteractiveSelection: true,
        textCapitalization: TextCapitalization.words,
        autocorrect: false,
        obscureText: widget.obscureText ?? false,
        controller: controller,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        autofocus: false,
        style: Theme.of(context).textTheme.bodyText1,
        onTap: widget.onTapped,
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: widget.errorText,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          hintText: widget.hint,
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
        keyboardType: widget.keyboardType,
      ),
    );
  }
}
