import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/select_services/select_services_view_model.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
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
    UpdateProviderInfoViewModel viewModel,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: ChangeNotifierProvider<SelectServicesViewModel>(
        create: (context) => SelectServicesViewModel(
          firestoreDatabase: firestoreDatabase,
          userProvider: userProvider,
        ),
        child: Consumer<SelectServicesViewModel>(
          builder: (_, model, __) => SelectServices(
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
      Routes.selectServices,
      arguments: {
        'model': model,
      },
    );
  }

  Future<void> submit(
    BuildContext context,
    UpdateProviderInfoViewModel viewModel,
  ) async {
    await model.saveServices();
    (viewModel.userProvider.user as ProviderUser).selectedServices =
        model.selectedServices;
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
