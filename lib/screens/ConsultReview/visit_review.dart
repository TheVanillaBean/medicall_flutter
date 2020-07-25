import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:swipe_gesture_recognizer/swipe_gesture_recognizer.dart';

class VisitReview extends StatelessWidget {
  final VisitReviewViewModel model;

  const VisitReview({@required this.model});

  static Widget create(BuildContext context, Consult consult) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return PropertyChangeProvider<VisitReviewViewModel>(
      value: VisitReviewViewModel(
        firestoreDatabase: firestoreDatabase,
        consult: consult,
      ),
      child: PropertyChangeConsumer<VisitReviewViewModel>(
        properties: [VisitReviewVMProperties.visitReview],
        builder: (_, model, __) => VisitReview(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitReview,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text("Visit Review"),
      ),
      body: SwipeGestureRecognizer(
        onSwipeLeft: () => model.incrementIndex(),
        onSwipeRight: () => model.decrementIndex(),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: IndexedStack(
                index: model.currentStep,
                children: <Widget>[
                  Container(
                    color: Colors.pink,
                    child: Center(
                      child: Text('Page 1'),
                    ),
                  ),
                  Container(
                    color: Colors.cyan,
                    child: Center(
                      child: Text('Page 2'),
                    ),
                  ),
                  Container(
                    color: Colors.deepPurple,
                    child: Center(
                      child: Text('Page 3'),
                    ),
                  ),
                  Container(
                    color: Colors.yellowAccent,
                    child: Center(
                      child: Text('Page 4'),
                    ),
                  ),
                  Container(
                    color: Colors.orange,
                    child: Center(
                      child: Text('Page 5'),
                    ),
                  ),
                  Container(
                    color: Colors.indigoAccent,
                    child: Center(
                      child: Text('Page 6'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: StepProgressIndicator(
                totalSteps: VisitReviewSteps.TotalSteps,
                padding: 20.0,
                currentStep: model.currentStep,
                size: 20,
                customColor: (index) => index == 0
                    ? Colors.redAccent
                    : index == 4 ? Colors.blueAccent : Colors.deepOrange,
                onTap: (index) => () => model.updateIndex(index),
              ),
            )
          ],
        ),
      ),
    );
  }
}
