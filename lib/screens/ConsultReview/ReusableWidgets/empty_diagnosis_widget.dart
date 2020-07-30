import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:flutter/material.dart';

import '../visit_review_view_model.dart';

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
        child: Container(
          child: Text("Please select a diagnosis first"),
        ),
      ),
    );
  }
}