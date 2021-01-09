import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/accepted_insurance/accepted_insurance_view_model.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcceptedInsurance extends StatelessWidget {
  final AcceptedInsuranceViewModel model;
  const AcceptedInsurance({@required this.model});

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
      child: ChangeNotifierProvider<AcceptedInsuranceViewModel>(
        create: (context) => AcceptedInsuranceViewModel(
          firestoreDatabase: firestoreDatabase,
          userProvider: userProvider,
        ),
        child: Consumer<AcceptedInsuranceViewModel>(
          builder: (_, model, __) => AcceptedInsurance(
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
      Routes.acceptedInsurance,
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
        title: "Accepted Insurance",
        theme: Theme.of(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('data'),
          Text('data'),
        ],
      ),
    );
  }
}
