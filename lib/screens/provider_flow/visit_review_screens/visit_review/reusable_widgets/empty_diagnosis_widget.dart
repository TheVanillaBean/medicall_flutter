import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';

class EmptyDiagnosis extends StatelessWidget {
  const EmptyDiagnosis({
    Key key,
    @required this.model,
  }) : super(key: key);

  final VisitReviewViewModel model;

  @override
  Widget build(BuildContext context) {
    return SwipeGestureRecognizer(
      onSwipeLeft: () => model.incrementIndex(),
      onSwipeRight: () => model.decrementIndex(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Please select a diagnosis first",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
