import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/edit_section_text_field.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class EditNoteSection extends StatelessWidget {
  static Widget create(
    BuildContext context,
    VisitReviewViewModel visitReviewViewModel,
  ) {
    return PropertyChangeProvider(
      value: visitReviewViewModel,
      child: EditNoteSection(),
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
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (model.patientNoteStepState.templateSection.keys.length >
                      1)
                    ..._buildCheckboxes(context, model),
                  Text(
                    model.patientNoteStepState.editNoteTitle,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 12),
                  for (String key
                      in model.patientNoteStepState.editedSection.keys)
                    ..._buildTextField(context, key, model),
                  Container(
                    width: width * .5,
                    child: SizedBox(
                      height: 40,
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
                        onPressed: () {
                          model.savedSectionUpdate();
                          Navigator.of(context).pop();
                        },
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

  List<Widget> _buildCheckboxes(
      BuildContext context, VisitReviewViewModel model) {
    return [
      CheckboxGroup(
        labels: model.patientNoteStepState.templateSection.keys.toList(),
        onChange: (isChecked, label, index) =>
            model.updateEditSectionCheckboxesWith(label, isChecked),
        checked: model.patientNoteStepState.editedSection.keys.toList(),
      ),
      SizedBox(height: 48),
    ];
  }

  List<Widget> _buildTextField(
      BuildContext context, String key, VisitReviewViewModel model) {
    String initialText = "";
    if (model.patientNoteStepState.editedSection.containsKey(key)) {
      initialText = model.patientNoteStepState.editedSection[key];
    } else {
      initialText = model.patientNoteStepState.templateSection[key];
    }
    return [
      if (key != "Template")
        Text(
          key,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      SizedBox(height: 12),
      EditSectionTextField(
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: null,
        initialText: initialText,
        labelText: 'Edit Section Note',
        hint: '',
        onChanged: (newText) => model.updateEditSectionWith(key, newText),
      ),
      SizedBox(height: 12),
    ];
  }
}
