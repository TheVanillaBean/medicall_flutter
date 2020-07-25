import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:flutter/material.dart';

import '../visit_review_view_model.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    Key key,
    @required this.width,
    @required this.model,
  }) : super(key: key);

  final double width;
  final VisitReviewViewModel model;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: width * .5,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SignInButton(
              text: "Continue",
              height: 16,
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () => model.incrementIndex(),
            ),
          ),
        ),
      ),
    );
  }
}
