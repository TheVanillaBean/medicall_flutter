import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:flutter/material.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    @required this.title,
    @required this.width,
    @required this.onTap,
  });

  final String title;
  final double width;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width * .5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReusableRaisedButton(
            title: title,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
