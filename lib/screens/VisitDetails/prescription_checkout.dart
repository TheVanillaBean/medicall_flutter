import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/VisitDetails/prescription_checkout_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:provider/provider.dart';

class PrescriptionCheckout extends StatefulWidget {
  final PrescriptionCheckoutViewModel model;

  PrescriptionCheckout({@required this.model});

  static Widget create(
    BuildContext context,
    String consultId,
    List<TreatmentOptions> treatmentOptions,
  ) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return ChangeNotifierProvider<PrescriptionCheckoutViewModel>(
      create: (context) => PrescriptionCheckoutViewModel(
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
        consultId: consultId,
        treatmentOptions: treatmentOptions,
      ),
      child: Consumer<PrescriptionCheckoutViewModel>(
        builder: (_, model, __) => PrescriptionCheckout(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    String consultId,
    List<TreatmentOptions> treatmentOptions,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.prescriptionCheckout,
      arguments: {
        'consultId': consultId,
        'treatmentOptions': treatmentOptions,
      },
    );
  }

  @override
  _PrescriptionCheckoutState createState() => _PrescriptionCheckoutState();
}

class _PrescriptionCheckoutState extends State<PrescriptionCheckout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Prescription Checkout",
        theme: Theme.of(context),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  CheckboxGroup(
                    labels: ["Finasteride, Minoxidil 5%, Biotin"],
                    itemBuilder: (Checkbox cb, Text txt, int i) {
                      return Row(
                        children: <Widget>[
                          cb,
                          Expanded(
                            child: Text(
                              txt.data,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
