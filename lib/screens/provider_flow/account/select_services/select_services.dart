import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/select_services/select_services_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectServices extends StatelessWidget {
  final SelectServicesViewModel model;
  const SelectServices({@required this.model});

  static Widget create(
    BuildContext context,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<SelectServicesViewModel>(
      create: (context) => SelectServicesViewModel(
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
      ),
      child: Consumer<SelectServicesViewModel>(
        builder: (_, model, __) => SelectServices(
          model: model,
        ),
      ),
    );
  }

  Future<void> submit(BuildContext context) async {
    model.saveServices();
    AppUtil()
        .showFlushBar("Successfully updated your offered services!", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Services",
        theme: Theme.of(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 12, 12, 12),
            child: Text(
              'Which services would you like to offer?',
              style: Theme.of(context).textTheme.bodyText1,
              //textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            child: CheckboxGroup(
              labelStyle: Theme.of(context).textTheme.bodyText1,
              labels: this.model.selectServices,
              onSelected: (List<String> checked) =>
                  this.model.updateWith(selectedServices: checked),
              checked: this.model.selectedServices,
            ),
          ),
          Center(
            child: ReusableRaisedButton(
              color: Theme.of(context).colorScheme.primary,
              title: 'Save',
              onPressed: model.canSubmit
                  ? () async {
                      await submit(context);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.selectServices,
    );
  }
}
