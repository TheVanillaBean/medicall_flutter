import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

abstract class CloseChatReasons {
  static const Visit_Concluded = "Visit concluded";
  static const Unrelated_To_Visit =
      "Patient asking questions not related to visit";
  static const Too_Many_Questions = "Patient asking too many questions";
  static const Inappropriate_Patient_Conduct = "Inappropriate patient conduct";
  static const Other = "Other";
  static const allReasons = [
    Visit_Concluded,
    Unrelated_To_Visit,
    Too_Many_Questions,
    Inappropriate_Patient_Conduct,
    Other,
  ];
}

class CloseChat extends StatefulWidget {
  final Consult consult;

  const CloseChat({
    @required this.consult,
  });

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.closeChat,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _CloseChatState createState() => _CloseChatState();
}

class _CloseChatState extends State<CloseChat> {
  List<String> reasonLabels = CloseChatReasons.allReasons;
  String selectedReason = CloseChatReasons.Visit_Concluded;
  String otherText = "";
  bool shouldMedicallContactPatient = false;
  bool submitted = false;
  bool readOnlyMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.consult.chatClosed != null) {
      readOnlyMode = true;
      this.selectedReason = widget.consult.chatClosed[ChatClosedKeys.REASON];
      this.shouldMedicallContactPatient =
          widget.consult.chatClosed[ChatClosedKeys.CONTACT_PATIENT] as bool;
      if (!CloseChatReasons.allReasons.contains(this.selectedReason)) {
        this.otherText = this.selectedReason;
        this.selectedReason = CloseChatReasons.Other;
      }
    }
  }

  Future<void> submit() async {
    FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    updateWith(submitted: true);
    Map<String, dynamic> visitClosed = {
      ChatClosedKeys.REASON: this.selectedReason == CloseChatReasons.Other
          ? this.otherText
          : this.selectedReason,
      ChatClosedKeys.CONTACT_PATIENT: this.shouldMedicallContactPatient,
    };
    widget.consult.chatClosed = visitClosed;
    await database.saveConsult(
        consult: widget.consult, consultId: widget.consult.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Close Chat",
        theme: Theme.of(context),
      ),
      body: KeyboardDismisser(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (this.readOnlyMode)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        child: Text(
                          '* You\'ve already closed this chat *',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Text(
                      'Why would you like to close the chat prior to the 72-hour window?',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    child: RadioButtonGroup(
                      disabled: readOnlyMode ? reasonLabels : null,
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      labels: reasonLabels,
                      picked: selectedReason,
                      onSelected: (String picked) =>
                          updateWith(selectedReason: picked),
                    ),
                  ),
                  if (this.selectedReason == CloseChatReasons.Other)
                    ..._buildOtherTextBox(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Text(
                      'Would you like the Medicall customer service team to contact the patient to help address this issue?',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    child: RadioButtonGroup(
                      disabled: readOnlyMode
                          ? [
                              'Yes',
                              'No',
                            ]
                          : null,
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      picked: this.shouldMedicallContactPatient ? "Yes" : "No",
                      onSelected: (String selected) => updateWith(
                          shouldMedicallContactPatient:
                              selected == "Yes" ? true : false),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: ReusableRaisedButton(
                        color: Theme.of(context).colorScheme.primary,
                        title: 'Continue',
                        onPressed: !readOnlyMode
                            ? () async {
                                try {
                                  await submit();
                                  Navigator.pop(context);
                                } catch (e) {
                                  AppUtil().showFlushBar(e, context);
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOtherTextBox() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          "What is the issue?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      SizedBox(
        height: 12,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          enabled: !this.readOnlyMode,
          textCapitalization: TextCapitalization.sentences,
          initialValue: this.otherText,
          autocorrect: true,
          maxLines: 3,
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

  bool get canSubmit {
    if (!this.submitted &&
        this.selectedReason == CloseChatReasons.Other &&
        this.otherText.length == 0) {
      return false;
    }
    return true;
  }

  void updateWith({
    bool submitted,
    String otherText,
    String selectedReason,
    bool shouldMedicallContactPatient,
  }) {
    setState(() {
      this.submitted = submitted ?? this.submitted;
      this.selectedReason = selectedReason ?? this.selectedReason;
      this.otherText = otherText ?? this.otherText;
      this.shouldMedicallContactPatient =
          shouldMedicallContactPatient ?? this.shouldMedicallContactPatient;
    });
  }
}
