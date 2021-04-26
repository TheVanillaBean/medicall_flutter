import 'dart:ui';

import 'package:Medicall/common_widgets/empty_visits.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/components/drawer_menu/drawer_menu.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/accepted_insurances/accepted_insurances.dart';
import 'package:Medicall/screens/provider_flow/account/nylas_connect/nylas_connect.dart';
import 'package:Medicall/screens/provider_flow/account/stripe_connect/stripe_connect.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard_list_item.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard_view_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_overview.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderDashboardScreen extends StatelessWidget {
  final ProviderDashboardViewModel model;

  const ProviderDashboardScreen({this.model});

  static Widget create(BuildContext context) {
    final FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider provider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<ProviderDashboardViewModel>(
      create: (context) => ProviderDashboardViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<ProviderDashboardViewModel>(
        builder: (_, model, __) => ProviderDashboardScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed,
  }) async {
    if (pushReplaceNamed) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.providerDashboard,
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.providerDashboard,
      );
    }
  }

  Future<void> consultItemPressed(BuildContext context, Consult consult) async {
    if (!(model.userProvider.user as ProviderUser).stripeConnectAuthorized) {
      StripeConnect.show(context: context, pushReplaceNamed: true);
    } else if (consult.state == ConsultStatus.Scheduled) {
      String url = await model.getVideoLink(consult);

      if (await canLaunch(url)) {
        await launch(url, enableJavaScript: true);
      } else {
        throw 'Could not launch url';
      }
    } else {
      VisitOverview.show(
        context: context,
        consultId: consult.uid,
        patientUser: consult.patientUser,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.home,
                color: Theme.of(context).appBarTheme.iconTheme.color,
              ),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Hello, ${model.userProvider.user.firstName}!',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      drawer: DrawerMenu(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
        child: Container(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * .05),
              child: Column(
                children: _buildChildren(context: context, height: height),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren({BuildContext context, double height}) {
    ProviderUser user = this.model.userProvider.user as ProviderUser;
    if (!user.stripeConnectAuthorized) {
      return [
        _buildNeedsStripeAuthHeader(context),
        SizedBox(
          height: height * 0.1,
        ),
      ];
    } else if (user.acceptedInsurances.length == 0) {
      return [
        _buildNeedsAcceptedInsurancesHeader(context),
        SizedBox(
          height: height * 0.1,
        ),
      ];
    } else if (!user.nylasConnected) {
      return [
        _buildNeedsNylasHeader(context),
        SizedBox(
          height: height * 0.1,
        ),
      ];
    } else {
      return [
        _buildStripeAuthorizedHeader(),
        SizedBox(
          height: height * 0.1,
        ),
      ];
    }
  }

  Widget _buildNeedsAcceptedInsurancesHeader(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "You have not selected your accepted insurances yet. This enables us to only allow patients to create a visit with you if you accept their insurance.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: 24),
          ReusableRaisedButton(
            title: "Select my accepted insurances",
            onPressed: () => AcceptedInsurances.show(context: context),
          ),
        ],
      ),
    );
  }

  Widget _buildStripeAuthorizedHeader() {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  "Current pending visits for you:",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListItemsBuilder<Consult>(
                  snapshot: consultSnapshot,
                  emptyContentWidget: EmptyVisits(
                    title: "",
                    message: "You do not have any pending visits to review",
                  ),
                  itemBuilder: (context, consult) => ProviderDashboardListItem(
                    consult: consult,
                    onTap: () async =>
                        await consultItemPressed(context, consult),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeedsStripeAuthHeader(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "You are not connected to Stripe. We use Stripe to send payouts to you for each visit you review.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: 24),
          ReusableRaisedButton(
            title: "Connect my account with Stripe",
            onPressed: () => StripeConnect.show(
              context: context,
              pushReplaceNamed: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsNylasHeader(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "You are not connected to Nylas. We use Nylas to handle dynamic scheduling for live visits.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: 24),
          ReusableRaisedButton(
            title: "Connect my account with Nylas",
            onPressed: () => NylasConnect.show(
              context: context,
              pushReplaceNamed: false,
            ),
          ),
        ],
      ),
    );
  }
}
