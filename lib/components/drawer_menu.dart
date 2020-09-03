import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/patient_flow/account/patient_account.dart';
import 'package:Medicall/screens/patient_flow/previous_visits/previous_visits.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptoms.dart';
import 'package:Medicall/screens/provider_flow/account/provider_account.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard.dart';
import 'package:Medicall/screens/provider_flow/provider_visits/provider_visits.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MedicallUser medicallUser =
        Provider.of<UserProvider>(context, listen: false).user;
    final EdgeInsets listContentPadding = EdgeInsets.fromLTRB(15, 5, 0, 5);
    return Container(
      width: 250,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: Image.asset(
                        'assets/icon/letter_mark.png',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: _buildNavigationItems(
                  listContentPadding,
                  context,
                  medicallUser,
                )),
          ],
        ),
      ),
    );
  }

  Column _buildNavigationItems(
    EdgeInsets listContentPadding,
    BuildContext context,
    MedicallUser medicallUser,
  ) {
    return Column(
      children: <Widget>[
        _buildHomeButton(listContentPadding, context, medicallUser),
        if (medicallUser.type == USER_TYPE.PATIENT)
          _buildNewVisitItem(listContentPadding, context, medicallUser),
        medicallUser.type == USER_TYPE.PROVIDER
            ? _buildProviderVisitsItem(listContentPadding, context)
            : _buildPatientVisitsItem(listContentPadding, context),
        _buildAccountItem(listContentPadding, context, medicallUser),
        Divider(
          height: 0,
          color: Colors.grey[400],
        ),
        _buildSignOutItem(listContentPadding, context)
      ],
    );
  }

  ListTile _buildSignOutItem(
      EdgeInsets listContentPadding, BuildContext context) {
    return ListTile(
      contentPadding: listContentPadding,
      title: Container(
        margin: EdgeInsets.only(left: 15),
        child: Text(
          'Sign Out',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      leading: Icon(
        Icons.close,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => _signOut(context),
    );
  }

  ListTile _buildAccountItem(EdgeInsets listContentPadding,
      BuildContext context, MedicallUser medicallUser) {
    return ListTile(
        contentPadding: listContentPadding,
        title: Container(
          margin: EdgeInsets.only(left: 15),
          child: Text(
            'Account',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        leading: Icon(
          Icons.account_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (medicallUser.type == USER_TYPE.PATIENT) {
            PatientAccountScreen.show(context: context);
          } else {
            ProviderAccountScreen.show(context: context);
          }
        });
  }

  ListTile _buildPatientVisitsItem(
      EdgeInsets listContentPadding, BuildContext context) {
    return ListTile(
        contentPadding: listContentPadding,
        title: Container(
          margin: EdgeInsets.only(left: 15),
          child: Text(
            'My Visits',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        leading: Icon(
          Icons.recent_actors,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          Navigator.of(context).pop();
          PreviousVisits.show(context: context);
        });
  }

  ListTile _buildProviderVisitsItem(
      EdgeInsets listContentPadding, BuildContext context) {
    return ListTile(
        contentPadding: listContentPadding,
        title: Container(
          margin: EdgeInsets.only(left: 15),
          child: Text(
            'My Visits',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        leading: Icon(
          Icons.recent_actors,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          Navigator.of(context).pop();
          ProviderVisits.show(context: context);
        });
  }

  ListTile _buildNewVisitItem(EdgeInsets listContentPadding,
      BuildContext context, MedicallUser medicallUser) {
    return ListTile(
        contentPadding: listContentPadding,
        title: Container(
          margin: EdgeInsets.only(left: 15),
          child: Text(
            'New Visit',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        leading: Icon(
          Icons.local_hospital,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          SymptomsScreen.show(context: context);
        });
  }

  ListTile _buildHomeButton(EdgeInsets listContentPadding, BuildContext context,
      MedicallUser medicallUser) {
    return ListTile(
      contentPadding: listContentPadding,
      title: Container(
        margin: EdgeInsets.only(left: 15),
        child: Text(
          'Home',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      leading: Icon(
        Icons.home,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        if (medicallUser.type == USER_TYPE.PATIENT) {
          PatientDashboardScreen.show(
            context: context,
            pushReplaceNamed: true,
          );
        } else {
          ProviderDashboardScreen.show(
            context: context,
            pushReplaceNamed: true,
          );
        }
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      Navigator.of(context).pop(context);
      final auth = Provider.of<AuthBase>(context, listen: false);
      final tempUserProvider =
          Provider.of<TempUserProvider>(context, listen: false);
      final ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      tempUserProvider.consult = null;
      if (chatProvider.client != null && chatProvider.userSet) {
        await chatProvider.client.disconnect(flushOfflineStorage: true);
      }
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
