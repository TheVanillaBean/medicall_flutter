import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientDashboardListItem extends StatelessWidget {
  const PatientDashboardListItem({Key key, @required this.consult, this.onTap})
      : super(key: key);
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);
    if (consult.providerUser != null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          leading: consult.providerUser.profilePic.length > 0
              ? displayProfilePicture(
                  extImageProvider, consult.providerUser.profilePic)
              : Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Colors.grey,
                ),
          title: Text(
            'Dr. ${consult.providerUser.fullName}',
          ),
          subtitle: Text("${consult.symptom} visit"),
          trailing: Text(
            EnumToString.parseCamelCase(consult.state) ?? "",
            style: TextStyle(color: Colors.blue),
          ),
          onTap: onTap,
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget displayProfilePicture(
      ExtendedImageProvider extImageProvider, String profilePicAddress) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.withAlpha(100),
      child: ClipOval(
        child: extImageProvider.returnNetworkImage(
          profilePicAddress,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
