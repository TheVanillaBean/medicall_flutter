import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_custom_text_field.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/email_assistant/email_assistant_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class EmailAssistant extends StatelessWidget {
  final EmailAssistantViewModel model;

  const EmailAssistant({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<EmailAssistantViewModel>(
      create: (context) => EmailAssistantViewModel(
        userProvider: userProvider,
        firestoreDatabase: firestoreDatabase,
        consult: consult,
      ),
      child: Consumer<EmailAssistantViewModel>(
        builder: (_, model, __) => EmailAssistant(
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
      Routes.emailAssistant,
      arguments: {
        'consult': consult,
      },
    );
  }

  Future<void> submit(
    BuildContext context,
  ) async {
    try {
      await model.sendSecureEmail();
      Navigator.pop(context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Email Assistant",
        theme: Theme.of(context),
      ),
      body: KeyboardDismisser(
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 12, 24),
                  child: ProviderCustomTextField(
                    initialText: model.assistantEmail,
                    labelText: 'Assistant Email',
                    hint: 'assistant@email.com',
                    errorText: model.emailErrorText,
                    onChanged: model.updateAssistantEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Text(
                    'Please select the reason:',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: RadioButtonGroup(
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    labels: this.model.selectReasons,
                    picked: this.model.selectedReason,
                    onSelected: (String picked) =>
                        model.updateWith(selectedReason: picked),
                  ),
                ),
                if (model.includeTextBox) ..._buildTextBox(context),
                CheckboxListTile(
                  contentPadding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                  title: Text(
                    'Please send a copy of my note to my assistant via secure email',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: this.model.checkValue ?? false,
                  onChanged: (bool newValue) {
                    try {
                      model.updateCheckValue(newValue);
                    } catch (e) {
                      AppUtil().showFlushBar(e, context);
                    }
                  },
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: ReusableRaisedButton(
                      color: Theme.of(context).colorScheme.primary,
                      title: 'Email Assistant',
                      onPressed: model.canSubmit
                          ? () async {
                              try {
                                await submit(context);
                                AppUtil().showFlushBar(
                                    "Successfully sent an email to your assistant",
                                    context);
                              } catch (e) {
                                AppUtil().showFlushBar(e, context);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 30),
                  child: Center(
                    child: Text(
                      'Emails are sent securely and are HIPAA compliant',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  List<Widget> _buildTextBox(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 12, 24),
        child: Text(
          "${this.model.selectedReason} note:",
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
          initialValue: "",
          autocorrect: true,
          minLines: 2,
          maxLines: 4,
          keyboardType: TextInputType.text,
          onChanged: this.model.updateEmailNote,
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
            labelText: "Enter any additional notes for your assistant",
            hintText: 'Optional',
          ),
        ),
      ),
      SizedBox(
        height: 12,
      ),
    ];
  }
}
