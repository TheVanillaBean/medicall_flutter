import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/accepted_insurances/accepted_insurances_view_model.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcceptedInsurances extends StatelessWidget {
  final AcceptedInsurancesViewModel model;
  const AcceptedInsurances({@required this.model});

  static Widget create(
    BuildContext context,
    UpdateProviderInfoViewModel viewModel,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: ChangeNotifierProvider<AcceptedInsurancesViewModel>(
        create: (context) => AcceptedInsurancesViewModel(
          firestoreDatabase: firestoreDatabase,
          userProvider: userProvider,
        ),
        child: Consumer<AcceptedInsurancesViewModel>(
          builder: (_, model, __) => AcceptedInsurances(
            model: model,
          ),
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    UpdateProviderInfoViewModel model,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.acceptedInsurances,
      arguments: {
        'model': model,
      },
    );
  }

  Future<void> submit(
    BuildContext context,
    UpdateProviderInfoViewModel viewModel,
  ) async {
    await model.saveInsurances();
    (viewModel.userProvider.user as ProviderUser).acceptedInsurances =
        model.acceptedInsurances;
    viewModel.updateWith();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    UpdateProviderInfoViewModel updateProviderInfoViewModel =
        Provider.of<UpdateProviderInfoViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Accepted Insurances",
        theme: Theme.of(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: ChipsChoice<String>.multiple(
                value: model.acceptedInsurances,
                onChanged: (val) => model.updateWith(acceptedInsurances: val),
                choiceItems: C2Choice.listFrom<String, String>(
                  source: model.selectInsurances,
                  value: (i, v) => v,
                  label: (i, v) => v,
                ),
                wrapped: true,
                choiceActiveStyle: C2ChoiceStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ReusableRaisedButton(
              color: Theme.of(context).colorScheme.primary,
              title: 'Save',
              onPressed: model.canSubmit
                  ? () async {
                      await submit(context, updateProviderInfoViewModel);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
