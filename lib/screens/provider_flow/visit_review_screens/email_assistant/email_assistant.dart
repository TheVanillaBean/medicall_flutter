import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_custom_text_field.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/email_assistant/email_assistant_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
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
    await model.sendSecureEmail();
    Navigator.pop(context);
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
                    initialText: '',
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
                //Spacer(),
                CheckboxListTile(
                  contentPadding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                  title: Text(
                    'Please send a copy of my note to my office manager via secure email',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: this.model.checkValue ?? false,
                  onChanged: model.updateCheckValue,
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
                              await submit(context);
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
}
