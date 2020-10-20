import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProviderBioTextField extends StatefulWidget {
  const ProviderBioTextField({
    this.onChanged,
    this.icon,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.enabled,
    this.errorText,
    this.inputFormatters,
    this.onTapped,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.initialText,
  });
  final ValueChanged<String> onChanged;
  final Icon icon;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String errorText;
  final FormFieldValidator<String> validator;
  final List<TextInputFormatter> inputFormatters;
  final GestureTapCallback onTapped;
  final maxLines;
  final minLines;
  final maxLength;
  final String initialText;

  @override
  _ProviderBioTextFieldState createState() => _ProviderBioTextFieldState();
}

class _ProviderBioTextFieldState extends State<ProviderBioTextField> {
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
        maxLength: widget.maxLength,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: false,
        controller: controller,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        autofocus: true,
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
//        validator: (input) {
//          if (input.isEmpty) {
//            return '$labelText is required';
//          }
//          return null;
//        },
      ),
    );
  }
}
