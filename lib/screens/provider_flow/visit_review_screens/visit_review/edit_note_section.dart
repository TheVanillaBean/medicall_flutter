import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class EditNoteSection extends StatelessWidget {
  static Widget create(
    BuildContext context,
    VisitReviewViewModel visitReviewViewModel,
  ) {
    return PropertyChangeProvider(
      value: visitReviewViewModel,
      child: Consumer<VisitReviewViewModel>(
        builder: (_, model, __) => EditNoteSection(),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    VisitReviewViewModel visitReviewViewModel,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.editNoteSection,
      arguments: {
        'visitReviewViewModel': visitReviewViewModel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.patientNote],
    ).value;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Edit Section",
        theme: Theme.of(context),
        onPressed: () async {
          Navigator.of(context).pop();
        },
      ),
      body: KeyboardDismisser(
        child: SingleChildScrollView(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model.patientNoteStepState.title,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 12),
                  Text(
                    model.patientNoteStepState.body,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: width * .35,
                    child: SizedBox(
                      height: 30,
                      child: RaisedButton(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.primary,
                        disabledColor:
                            Theme.of(context).disabledColor.withOpacity(.3),
                        child: Text(
                          "Save and Continue",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(14),
                          ),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
