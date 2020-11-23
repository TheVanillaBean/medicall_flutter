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

abstract class OfficeVisitReasons {
  static const Not_Appropriate = "Not appropriate for teledermatology";
  static const Prefer_In_Person = "Prefer to see patient in person";
  static const Further_Testing = "Will need further testing";
  static const Other = "Other";
  static const allReasons = [
    Not_Appropriate,
    Prefer_In_Person,
    Further_Testing,
    Other,
  ];
}

class VisitOffice extends StatefulWidget {
  final Consult consult;

  VisitOffice({Key key, this.consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitOffice,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VisitOfficeState createState() => _VisitOfficeState();
}

class _VisitOfficeState extends State<VisitOffice> {
  String selectedReason = OfficeVisitReasons.Not_Appropriate;
  bool shouldAssistantScheduleVisit = false;
  String otherText = "";
  String note = "";
  bool submitted = false;
  bool showSuccessUI = false;

  Future<void> _saveToFirestore() async {
    this.updateWith(submitted: true);
    Database database = Provider.of<FirestoreDatabase>(context, listen: false);
    Map<String, dynamic> officeVisitMap = {
      VisitIssueKeys.ISSUE: VisitTroubleLabels.Redirect,
      VisitIssueKeys.REASON: this.selectedReason == OfficeVisitReasons.Other
          ? this.otherText
          : this.selectedReason,
      VisitIssueKeys.ASSISTANT_REACH_OUT: this.shouldAssistantScheduleVisit,
      VisitIssueKeys.BRIEF_NOTE: this.note,
    };

    widget.consult.visitIssue = officeVisitMap;

    await database.saveConsult(
        consultId: widget.consult.uid, consult: widget.consult);

    this.updateWith(showSuccessUI: true, submitted: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Office Visit",
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
                  ..._buildChildren(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get canSubmit {
    if (!this.submitted &&
        this.selectedReason == OfficeVisitReasons.Other &&
        this.otherText.length == 0) {
      return false;
    }
    if (!this.submitted && this.note.length == 0) {
      return false;
    }
    return true;
  }

  List<Widget> _buildChildren() {
    return [
      SizedBox(height: 16),
      ..._buildOptionsUI(),
      SizedBox(height: 32),
      if (this.selectedReason == OfficeVisitReasons.Other)
        ..._buildOtherTextBox(),
      ..._buildCheckbox(),
      SizedBox(height: 32),
      ..._buildTextBox(),
      SizedBox(height: 32),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "*Redirecting the visit to in person will result in the online visit fee being refunded to the patient.",
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.left,
          ),
        ),
      ),
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

  List<Widget> _buildOptionsUI() {
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Why are you recommending an in person visit?",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      SizedBox(height: 12),
      RadioButtonGroup(
        labelStyle: Theme.of(context).textTheme.bodyText1,
        activeColor: Theme.of(context).colorScheme.primary,
        labels: OfficeVisitReasons.allReasons,
        picked: this.selectedReason,
        onSelected: (String selected) async {
          this.updateWith(selectedReason: selected);
        },
      ),
    ];
  }

  List<Widget> _buildCheckbox() {
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Would you like your assistant to reach out and help the patient schedule a visit?",
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
        picked: this.shouldAssistantScheduleVisit ? "Yes" : "No",
        onSelected: (String selected) async {
          this.updateWith(
              shouldAssistantScheduleVisit: selected == "Yes" ? true : false);
        },
      ),
    ];
  }

  List<Widget> _buildTextBox() {
    return [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "We recommend that you write a brief note to the patient explaining why you prefer to see them in person.",
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
          initialValue: this.note,
          maxLines: 10,
          minLines: 6,
          autocorrect: true,
          keyboardType: TextInputType.text,
          onChanged: (String text) => this.updateWith(note: text),
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
            labelText: "Note for patient",
            hintText: '',
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOtherTextBox() {
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
      TextFormField(
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
      SizedBox(
        height: 12,
      ),
    ];
  }

  List<Widget> _buildSuccessUI() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
        child: Text(
          "Refund Issued",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
        child: Text(
          "We will process the refund and notify the patient. If you have any further questions, you can email omar@medicall.com with your inquiry.",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  void updateWith({
    String selectedReason,
    bool shouldAssistantScheduleVisit,
    String otherText,
    String note,
    bool submitted,
    bool showSuccessUI,
  }) {
    setState(() {
      this.selectedReason = selectedReason ?? this.selectedReason;
      this.shouldAssistantScheduleVisit =
          shouldAssistantScheduleVisit ?? this.shouldAssistantScheduleVisit;
      this.otherText = otherText ?? this.otherText;
      this.note = note ?? this.note;
      this.submitted = submitted ?? this.submitted;
      this.showSuccessUI = showSuccessUI ?? this.showSuccessUI;
    });
  }
}
