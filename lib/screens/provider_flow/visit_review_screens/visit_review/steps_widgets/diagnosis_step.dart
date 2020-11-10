import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/direct_select.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/diagnosis_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class DiagnosisStep extends StatelessWidget {
  final DiagnosisStepState model;

  const DiagnosisStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        Provider.of<VisitReviewViewModel>(context);
    return ChangeNotifierProvider<DiagnosisStepState>(
      create: (context) => DiagnosisStepState(
        visitReviewViewModel: visitReviewViewModel,
      ),
      child: Consumer<DiagnosisStepState>(
        builder: (_, model, __) => DiagnosisStep(
          model: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return KeyboardDismisser(
          gestures: [GestureType.onTap],
          child: SwipeGestureRecognizer(
            onSwipeLeft: () => model.visitReviewViewModel.incrementIndex(),
            onSwipeRight: () => model.visitReviewViewModel.decrementIndex(),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ..._buildChildren(context),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return [
      ..._buildDiagnosisDropdown(),
      SizedBox(height: 12),
      if (model.diagnosis == "Other") _buildOtherDiagnosisTextView(context),
      ..._buildIncludeDDXToggle(context, width),
      if (model.includeDDX) _buildDDXOptionsCheckbox(),
      if (model.selectedDDXOptions.contains("Other") && model.includeDDX)
        _buildOtherDDXOptionTextView(context),
      SizedBox(height: 8),
      Expanded(
        child: ContinueButton(
          title: "Save and Continue",
          width: width,
          onTap: this.model.minimumRequiredFieldsFilledOut
              ? () async {
                  model.visitReviewViewModel.saveDiagnosisToFirestore(model);
                  model.visitReviewViewModel.incrementIndex();
                }
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildDiagnosisDropdown() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
        child: Text(
          "What is your diagnosis for this patient?",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      DirectSelect(
        itemExtent: 60.0,
        selectedIndex: model.selectedItemIndex,
        child: CustomSelectionItem(
          isForList: false,
          title: model.diagnosis,
        ),
        onSelectedItemChanged: (index) async =>
            await model.updateReviewOptionsForDiagnosis(index),
        items: _buildDiagnosisItem(),
      ),
    ];
  }

  Widget _buildOtherDiagnosisTextView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        initialValue: model.otherDiagnosis,
        autocorrect: true,
        keyboardType: TextInputType.text,
        onChanged: (String text) =>
            model.updateDiagnosisStepWith(otherDiagnosis: text),
        style: Theme.of(context).textTheme.bodyText2,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
          ),
          hintStyle: TextStyle(
            color: Color.fromRGBO(100, 100, 100, 1),
          ),
          filled: true,
          fillColor: Colors.grey.withAlpha(20),
          labelText: "Enter Diagnosis",
          hintText: 'Custom Diagnosis',
        ),
      ),
    );
  }

  List<Widget> _buildIncludeDDXToggle(BuildContext context, double width) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
        child: Text(
          "Would you like to include a ddx?",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Container(
        width: width * 0.8,
        child: RadioButtonGroup(
          activeColor: Theme.of(context).colorScheme.primary,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          labels: <String>[
            "No",
            "Yes",
          ],
          picked: model.includeDDX ? "Yes" : "No",
          onSelected: (String selected) async {
            try {
              model.updateDiagnosisStepWith(
                  includeDDX: selected == "Yes" ? true : false);
            } catch (e) {
              AppUtil()
                  .showFlushBar("Please select a diagnosis first", context);
            }
          },
        ),
      ),
    ];
  }

  Widget _buildDDXOptionsCheckbox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 0, 0, 16),
      child: CheckboxGroup(
        labels: model.visitReviewViewModel.consultReviewOptions
                .ddxOptions[model.diagnosis] ??
            [],
        onSelected: (List<String> checked) =>
            model.updateDiagnosisStepWith(selectedDDXOptions: checked),
        checked: model.selectedDDXOptions,
      ),
    );
  }

  Widget _buildOtherDDXOptionTextView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        initialValue: model.ddxOtherOption,
        autocorrect: true,
        keyboardType: TextInputType.text,
        onChanged: (String text) =>
            model.updateDiagnosisStepWith(ddxOtherOption: text),
        style: Theme.of(context).textTheme.bodyText2,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
          ),
          hintStyle: TextStyle(
            color: Color.fromRGBO(100, 100, 100, 1),
          ),
          filled: true,
          fillColor: Colors.grey.withAlpha(20),
          labelText: "Enter DDX Option",
          hintText: 'Optional',
        ),
      ),
    );
  }

  List<Widget> _buildDiagnosisItem() {
    return model.visitReviewViewModel.consultReviewOptions.diagnosisList
        .map((val) => CustomSelectionItem(
              title: val,
            ))
        .toList();
  }
}

class CustomSelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const CustomSelectionItem({Key key, this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: EdgeInsets.all(10.0),
            )
          : Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: AutoSizeText(
        title,
        style: TextStyle(fontSize: 20),
        maxLines: 2,
      ),
    );
  }
}
