import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/drivers_license/photo_id.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info.dart';
import 'package:Medicall/screens/patient_flow/previous_visits/previous_visits_list_item.dart';
import 'package:Medicall/screens/patient_flow/previous_visits/previous_visits_view_model.dart';
import 'package:Medicall/screens/patient_flow/schedule_visit/schedule_visit.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_details_overview.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviousVisits extends StatelessWidget {
  final PreviousVisitsViewModel model;
  const PreviousVisits({@required this.model});

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<PreviousVisitsViewModel>(
      create: (context) => PreviousVisitsViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<PreviousVisitsViewModel>(
        builder: (_, model, __) => PreviousVisits(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.previousConsults,
    );
  }

  void _navigateToVisitPayment(BuildContext context, Consult consult) {
    if ((model.userProvider.user as PatientUser).photoID.length > 0) {
      //photo ID check
      if ((model.userProvider.user as PatientUser).fullName.length > 2 &&
          (model.userProvider.user as PatientUser).profilePic.length > 2 &&
          (model.userProvider.user as PatientUser).mailingAddress.length > 2) {
        if (consult.visitType == VisitType.Live &&
            consult.state == ConsultStatus.NeedsScheduling) {
          ScheduleVisit.show(
              context: context, pushReplaceNamed: true, consult: consult);
        } else {
          MakePayment.show(context: context, consult: consult);
        }
      } else {
        PersonalInfoScreen.show(context: context, consult: consult);
      }
    } else {
      PhotoIDScreen.show(
          context: context, pushReplaceNamed: true, consult: consult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "My Visits",
        theme: Theme.of(context),
      ),
      body: _buildChildren(),
    );
  }

  Widget _buildChildren({BuildContext context, double height}) {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Scrollbar(
          child: ListItemsBuilder<Consult>(
            snapshot: consultSnapshot,
            itemBuilder: (context, consult) => PreviousVisitsListItem(
              consult: consult,
              onTap: () => consult.state == ConsultStatus.PendingPayment ||
                      consult.state == ConsultStatus.ReferralRequested
                  ? _navigateToVisitPayment(context, consult)
                  : VisitDetailsOverview.show(
                      context: context,
                      consult: consult,
                    ),
            ),
          ),
        );
      },
    );
  }
}
