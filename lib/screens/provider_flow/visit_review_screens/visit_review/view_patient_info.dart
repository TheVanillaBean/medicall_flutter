import 'package:Medicall/common_widgets/reusable_account_card.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewPatientInfo extends StatelessWidget {
  final Consult consult;

  const ViewPatientInfo({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.viewPatientInfo,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text("Patient Information"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: FutureBuilder<MedicallUser>(
              future: db.userStream(USER_TYPE.PATIENT, consult.patientId).first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    return Column(
                      children: _buildChildren(snapshot.data),
                    );
                  } else {
                    return Center(
                      child:
                          Text("Patient information could not be retrieved..."),
                    );
                  }
                }
              }),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(MedicallUser medicallUser) {
    return [
      _buildNameCard(medicallUser),
      _buildDOBCard(medicallUser),
      _buildAddressCard(medicallUser)
    ];
  }

  Widget _buildNameCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Full Name:',
      title: "${medicallUser.firstName} ${medicallUser.lastName}",
    );
  }

  Widget _buildDOBCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'DOB:',
      title: medicallUser.dob != null && medicallUser.dob.length > 0
          ? medicallUser.dob
          : 'N/A',
    );
  }

  Widget _buildAddressCard(MedicallUser medicallUser) {
    return ReusableAccountCard(
      leading: 'Mailing \nAddress:',
      title: medicallUser.mailingAddressLine2 == ''
          ? '${medicallUser.mailingAddress} \n${medicallUser.mailingCity}, ${medicallUser.mailingState} ${medicallUser.mailingZipCode}'
          : '${medicallUser.mailingAddress} \n${medicallUser.mailingAddressLine2} \n${medicallUser.mailingCity}, ${medicallUser.mailingState} ${medicallUser.mailingZipCode}',
    );
  }
}
