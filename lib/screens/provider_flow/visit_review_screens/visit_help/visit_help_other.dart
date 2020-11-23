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

class VisitHelpOther extends StatefulWidget {
  final Consult consult;

  VisitHelpOther({Key key, this.consult}) : super(key: key);

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.visitHelpOther,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VisitHelpOtherState createState() => _VisitHelpOtherState();
}

class _VisitHelpOtherState extends State<VisitHelpOther> {
  String explanation = "";
  bool refund = false;
  bool shouldMedicallAddressIssue = false;
  bool submitted = false;
  bool showSuccessUI = false;

  Future<void> _saveToFirestore() async {
    this.updateWith(submitted: true);
    Database database = Provider.of<FirestoreDatabase>(context, listen: false);
    Map<String, dynamic> patientConduct = {
      VisitIssueKeys.ISSUE: VisitTroubleLabels.Patient_Satisfaction,
      VisitIssueKeys.EXPLANATION: this.explanation,
      VisitIssueKeys.SHOULD_REFUND: this.refund,
      VisitIssueKeys.MEDICALL_ADDRESS_ISSUE: this.shouldMedicallAddressIssue,
    };

    widget.consult.visitIssue = patientConduct;

    await database.saveConsult(
        consultId: widget.consult.uid, consult: widget.consult);

    this.updateWith(showSuccessUI: true, submitted: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Patient Conduct",
        theme: Theme.of(context),
      ),
      body: KeyboardDismisser(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                if (this.showSuccessUI)
                  ..._buildSuccessUI()
                else
                  ..._buildChildren()
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get canSubmit {
    if (!this.submitted && this.explanation.length > 0) {
      return true;
    }
    return false;
  }

  List<Widget> _buildChildren() {
    return [
      SizedBox(height: 16),
      ..._buildExplanationTextBox(),
      SizedBox(height: 32),
      ..._buildIssueRefundCheckbox(),
      SizedBox(height: 32),
      ..._buildAddressIssueCheckbox(),
      SizedBox(height: 16),
      Padding(
        padding: EdgeInsets.fromLTRB(36, 20, 36, 15),
        child: ContinueButton(
          title: "Continue",
          width: ScreenUtil.screenWidthDp,
          onTap: this.canSubmit
              ? () async {
                  await _saveToFirestore();
                }
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildExplanationTextBox() {
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Can you please tell us more?",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          initialValue: this.explanation,
          maxLines: 8,
          minLines: 5,
          autocorrect: true,
          keyboardType: TextInputType.text,
          onChanged: (String text) => this.updateWith(explanation: text),
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
            labelText: "Explanation:",
            hintText: '',
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildIssueRefundCheckbox() {
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Would you like to issue a refund?",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      SizedBox(height: 12),
      RadioButtonGroup(
        labelStyle: Theme.of(context).textTheme.bodyText1,
        activeColor: Theme.of(context).colorScheme.primary,
        labels: ["Yes", "No"],
        picked: this.refund ? "Yes" : "No",
        onSelected: (String selected) async {
          this.updateWith(refund: selected == "Yes" ? true : false);
        },
      ),
    ];
  }

  List<Widget> _buildAddressIssueCheckbox() {
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Would you like the Medicall customer service team to help address this issue?",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      SizedBox(height: 12),
      RadioButtonGroup(
        labelStyle: Theme.of(context).textTheme.bodyText1,
        activeColor: Theme.of(context).colorScheme.primary,
        labels: ["Yes", "No"],
        picked: this.shouldMedicallAddressIssue ? "Yes" : "No",
        onSelected: (String selected) async {
          this.updateWith(
              shouldMedicallAddressIssue: selected == "Yes" ? true : false);
        },
      ),
    ];
  }

  List<Widget> _buildSuccessUI() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
        child: Text(
          "Thank You",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
        child: Text(
          "Our team will be reaching out to you to discuss next steps. If you have any further questions, you can email omar@medicall.com with your inquiry.",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  void updateWith({
    String explanation,
    bool refund,
    bool shouldMedicallAddressIssue,
    bool submitted,
    bool showSuccessUI,
  }) {
    setState(() {
      this.explanation = explanation ?? this.explanation;
      this.refund = refund ?? this.refund;
      this.shouldMedicallAddressIssue =
          shouldMedicallAddressIssue ?? this.shouldMedicallAddressIssue;
      this.submitted = submitted ?? this.submitted;
      this.showSuccessUI = showSuccessUI ?? this.showSuccessUI;
    });
  }
}
