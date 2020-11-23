import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

abstract class PoorInfoReasons {
  static const Clinical_History = "Clinical History";
  static const Photographs = "Photographs";
  static const Other = "Other";
  static const allReasons = [
    Clinical_History,
    Photographs,
    Other,
  ];
}

class VisitPoorInfo extends StatefulWidget {
  final Consult consult;

  VisitPoorInfo({Key key, this.consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitPoorInfo,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VisitPoorInfoState createState() => _VisitPoorInfoState();
}

class _VisitPoorInfoState extends State<VisitPoorInfo> {
  String selectedReason = PoorInfoReasons.Clinical_History;
  String otherText = "";
  bool submitted = false;
  bool showSuccessUI = false;

  Future<void> _saveToFirestore() async {
    this.updateWith(submitted: true);
    Database database = Provider.of<FirestoreDatabase>(context, listen: false);
    Map<String, dynamic> poorInfoMap;
    if (this.selectedReason == PoorInfoReasons.Other) {
      poorInfoMap = {
        VisitIssueKeys.ISSUE: VisitTroubleLabels.Poor_Quality,
        VisitIssueKeys.REASON: this.otherText,
      };
    } else {
      poorInfoMap = {
        VisitIssueKeys.ISSUE: VisitTroubleLabels.Poor_Quality,
        VisitIssueKeys.REASON: this.selectedReason,
      };
    }

    widget.consult.visitIssue = poorInfoMap;

    await database.saveConsult(
        consultId: widget.consult.uid, consult: widget.consult);

    this.updateWith(showSuccessUI: true, submitted: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Visit Quality",
        theme: Theme.of(context),
      ),
      body: KeyboardDismisser(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  if (this.showSuccessUI)
                    ...this._buildSuccessUI()
                  else
                    ...this._buildChildren()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get canSubmit {
    if (!this.submitted &&
        this.selectedReason == PoorInfoReasons.Other &&
        this.otherText.length == 0) {
      return false;
    }
    return true;
  }

  List<Widget> _buildChildren() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
        child: Center(
          child: Text(
            "Is there particular information that is missing, inadequate, or of poor quality?",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: RadioButtonGroup(
          labelStyle: Theme.of(context).textTheme.bodyText1,
          activeColor: Theme.of(context).colorScheme.primary,
          labels: PoorInfoReasons.allReasons,
          picked: this.selectedReason,
          onSelected: (String selected) =>
              this.updateWith(selectedReason: selected),
        ),
      ),
      if (this.selectedReason == PoorInfoReasons.Other)
        ..._buildOtherTextBox(context),
      Expanded(
        child: ContinueButton(
          title: "Continue",
          width: ScreenUtil.screenWidthDp - 60,
          onTap: this.canSubmit
              ? () async {
                  await _saveToFirestore();
                }
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildSuccessUI() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
        child: Center(
          child: Text(
            "You've successfully submitted this issue.",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
        child: Center(
          child: Text(
            "We will reach out to the patient and address your concerns. You will receive a follow up from the Medicall team shortly.",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOtherTextBox(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          "What is the issue?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          initialValue: this.otherText,
          autocorrect: true,
          keyboardType: TextInputType.text,
          onChanged: (String text) => this.updateWith(otherText: text),
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
            labelText: "",
            hintText: '',
          ),
        ),
      ),
      SizedBox(
        height: 12,
      ),
    ];
  }

  void updateWith({
    String selectedReason,
    String otherText,
    bool submitted,
    bool showSuccessUI,
  }) {
    setState(() {
      this.selectedReason = selectedReason ?? this.selectedReason;
      this.submitted = submitted ?? this.submitted;
      this.otherText = otherText ?? this.otherText;
      this.showSuccessUI = showSuccessUI ?? this.showSuccessUI;
    });
  }
}
