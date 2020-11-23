import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/edit_note/edit_note_view_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/edit_section_text_field.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class EditNoteSection extends StatelessWidget {
  final EditNoteViewModel model;

  const EditNoteSection({@required this.model});

  static Widget create(
    BuildContext context,
    PatientNoteSection section,
    String sectionTitle,
    Map<String, String> templateSection,
    Map<String, String> editedSection,
  ) {
    return ChangeNotifierProvider<EditNoteViewModel>(
      create: (context) => EditNoteViewModel(
        section: section,
        sectionTitle: sectionTitle,
        templateSection: templateSection,
        editedSection: editedSection,
      ),
      child: Consumer<EditNoteViewModel>(
        builder: (_, model, __) => EditNoteSection(
          model: model,
        ),
      ),
    );
  }

  static Future<Map<String, String>> show({
    BuildContext context,
    PatientNoteSection section,
    String sectionTitle,
    Map<String, String> templateSection,
    Map<String, String> editedSection,
  }) async {
    return await Navigator.of(context).pushNamed(
      Routes.editNoteSection,
      arguments: {
        'section': section,
        'sectionTitle': sectionTitle,
        'templateSection': templateSection,
        'editedSection': editedSection,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Edit Section",
        theme: Theme.of(context),
        onPressed: () => Navigator.of(context).pop(),
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
                  if (model.templateSection.keys.length > 1)
                    ..._buildCheckboxes(context),
                  Text(
                    model.sectionTitle,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 12),
                  if (model.templateSection.keys.length == 1)
                    for (String key in model.templateSection.keys)
                      ..._buildTextField(context, key)
                  else
                    for (String key in model.editedSection.keys)
                      ..._buildTextField(context, key),
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
                        onPressed: model.noteEdited
                            ? () =>
                                Navigator.of(context).pop(model.editedSection)
                            : null,
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

  List<Widget> _buildCheckboxes(BuildContext context) {
    return [
      CheckboxGroup(
        labels: model.templateSection.keys.toList(),
        onChange: (isChecked, label, index) =>
            model.updateEditSectionCheckboxesWith(label, isChecked),
        checked: model.editedSection.keys.toList(),
      ),
      SizedBox(height: 48),
    ];
  }

  List<Widget> _buildTextField(BuildContext context, String key) {
    String initialText = model.editedSection[key];
    if (model.editedSection.containsKey(key)) {
      initialText = model.editedSection[key];
    } else {
      initialText = model.templateSection[key];
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
