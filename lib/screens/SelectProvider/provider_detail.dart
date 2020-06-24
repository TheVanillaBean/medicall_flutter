import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/registration.dart';
import 'package:Medicall/screens/Welcome/start_visit.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Symptom symptom;
  final MedicallUser provider;

  const ProviderDetailScreen({@required this.symptom, @required this.provider});

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
    MedicallUser provider,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.providerDetail,
      arguments: {
        'symptom': symptom,
        'provider': provider,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);

    MedicallUser medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).medicallUser;
    } catch (e) {}

    ScreenUtil.init(context);
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
        title: Text(
          provider.displayName + ' ' + provider.titles,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: ScreenUtil.screenHeightDp - (ScreenUtil.statusBarHeight + 50),
          color: Colors.white,
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildChildren(
              tempUserProvider,
              extImageProvider,
              medicallUser,
              context,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(
    TempUserProvider tempUserProvider,
    ExtendedImageProvider extImageProvider,
    MedicallUser medicallUser,
    BuildContext context,
  ) {
    return <Widget>[
      CircleAvatar(
        radius: 50.0,
        child: ClipOval(
          child: extImageProvider.returnNetworkImage(
            provider.profilePic,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      SizedBox(height: 10),
      Text(
        'Dermatologist',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 10),
      Container(
        alignment: Alignment.center,
        width: 150,
        child: Text(
          provider.address,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 30),
      Expanded(
        flex: 5,
        child: Container(
          child: Text(
            symptom.description,
            style: TextStyle(
              height: 1.6,
              fontSize: 14,
              letterSpacing: 0.6,
              wordSpacing: 1,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: FlatButton(
          color: Colors.blue,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            'Start Visit',
            style: TextStyle(fontSize: 14),
          ),
          onPressed: () {
            Consult consult = Consult(
              providerId: provider.uid,
              symptom: symptom.name,
              date: DateTime.now(),
            );
            if (medicallUser != null) {
              StartVisitScreen.show(
                context: context,
                consult: consult,
              );
            } else {
              tempUserProvider.consult = consult;
              RegistrationScreen.show(context: context);
            }
          },
        ),
      )
    ];
  }
}
