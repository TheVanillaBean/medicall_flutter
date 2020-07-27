import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

import '../visit_review_view_model.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    Key key,
    @required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.continueBtn],
    ).value;
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: width * .5,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SignInButton(
              text: "Save and Continue",
              height: 16,
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: model.canContinue && !model.continueBtnPressed
                  ? () async {
                      model.updateContinueBtnPressed(true);
                      await model.saveVisitReviewToFirestore();
                      model.incrementIndex();
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
