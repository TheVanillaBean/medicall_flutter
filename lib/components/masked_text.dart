library masked_text;

import 'package:flutter/material.dart';

// Adapted from https://pub.dartlang.org/packages/masked_text

class MaskedTextField extends StatefulWidget {
  final TextEditingController maskedTextFieldController;
  final ValueSetter<String> onSubmitted;

  final String mask;
  final String escapeCharacter;

  final int maxLength;
  final TextInputType keyboardType;
  final InputDecoration inputDecoration;
  final TextAlign textAlign;
  final TextStyle style;

  final ValueSetter<String> onChanged;

  const MaskedTextField({
    Key key,
    this.mask,
    this.style,
    this.textAlign,
    this.maskedTextFieldController,
    this.onSubmitted,
    this.escapeCharacter: 'x',
    this.maxLength: 100,
    this.keyboardType: TextInputType.text,
    this.inputDecoration: const InputDecoration(),
    this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MaskedTextFieldState();
}

class MaskedTextFieldState extends State<MaskedTextField> {
  @override
  Widget build(BuildContext context) {
    var lastTextSize = 0;

    return TextField(
      controller: widget.maskedTextFieldController,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      decoration: widget.inputDecoration,
      textAlign: widget.textAlign ?? TextAlign.start,
      style: widget.style ?? Theme.of(context).textTheme.subhead,
      onSubmitted: (String text) => widget?.onSubmitted(unmaskedText),
      onChanged: (String text) {
        // Deleting/removing
        if (text.length < lastTextSize) {
          if (widget.mask[text.length] != widget.escapeCharacter) {
            widget.maskedTextFieldController.selection =
                TextSelection.fromPosition(
              TextPosition(
                  offset: widget.maskedTextFieldController.text.length),
            );

            widget?.onChanged(unmaskedText);
          }
        } else {
          // Typing
          if (text.length >= lastTextSize) {
            var position = text.length;

            if ((widget.mask[position - 1] != widget.escapeCharacter) &&
                (text[position - 1] != widget.mask[position - 1])) {
              widget.maskedTextFieldController.text = _buildText(text);
            }

            if (widget.mask[position] != widget.escapeCharacter) {
              widget.maskedTextFieldController.text =
                  '${widget.maskedTextFieldController.text}${widget.mask[position]}';
            }

            widget.onChanged(unmaskedText);
          }

          // Android's onChange resets cursor position (cursor goes to 0)
          // so you have to check if it was reset, then put in the end
          // as iOS bugs if you simply put it in the end
          if (widget.maskedTextFieldController.selection.start <
              widget.maskedTextFieldController.text.length) {
            widget.maskedTextFieldController.selection =
                TextSelection.fromPosition(TextPosition(
                    offset: widget.maskedTextFieldController.text.length));
          }
        }

        // Updating cursor position
        lastTextSize = widget.maskedTextFieldController.text.length;

        widget.onChanged(unmaskedText);
      },
    );
  }

  String _buildText(String text) {
    var result = '';

    for (int i = 0; i < text.length - 1; i++) {
      result += text[i];
    }

    result += widget.mask[text.length - 1];
    result += text[text.length - 1];

    return result;
  }

  String get unmaskedText {
    final filteredMasks = widget.mask
        .splitMapJoin(widget.escapeCharacter, onMatch: (m) => '')
        .split('');
    String text = widget.maskedTextFieldController.text.trim();
    for (String character in filteredMasks) {
      text = text.replaceAll(character, '');
    }
    return text;
  }
}
