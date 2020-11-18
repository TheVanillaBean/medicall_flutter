import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/email_assistant/email_assistant_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider<EmailAssistantViewModel>(
      create: (context) => EmailAssistantViewModel(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Email Assistant",
        theme: Theme.of(context),
      ),
      body: Column(),
    );
  }
}
